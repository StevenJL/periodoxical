require "periodoxical/version"
require "date"
require "time"
require "tzinfo"
require "week_of_month"

module Periodoxical
  class << self
    def generate(**opts)
      Core.new(**opts).generate
    end
  end

  class Core
    VALID_DAYS_OF_WEEK = %w[mon tue wed thu fri sat sun].freeze
    # @param [String] time_zone
    #   Ex: 'America/Los_Angeles', 'America/Chicago',
    #   TZInfo::DataTimezone#name from the tzinfo gem (https://github.com/tzinfo/tzinfo)
    # @param [Date, String] start_date
    # @param [Date, String] end_date
    # @param [Array<Hash>] time_blocks
    #   Ex: [
    #     {
    #       start_time: '9:00AM',
    #       end_time: '10:30PM'
    #     },
    #     {
    #       start_time: '2:00PM',
    #       end_time: '2:30PM'
    #     }
    #   ]
    # @param [Array<String>, nil] days_of_week
    #   Days of the week to generate the times for, if nil, then times are generated
    #   for every day.
    #   Ex: %w(mon tue wed sat)
    # @param [Array<Integer>, nil] days_of_month
    #   Days of month to generate times for.
    #   Ex: %w(5 10) - The 5th and 10th days of every month
    # @param [Array<Integer>, nil] months
    #   Months as integers, where 1 = Jan, 12 = Dec
    # @param [Integer] limit
    #   How many date times to generate.  To be used when `end_date` is nil.
    # @param [Aray<String>] exclusion_dates
    #   Dates to be excluded when generating the time blocks
    #   Ex: ['2024-06-10', '2024-06-14']
    # @param [Hash<Array<Hash>>] day_of_week_time_blocks
    #   To be used when hours are different between days of the week
    #   Ex: {
    #     mon: [{ start_time: '10:15AM', end_time: '11:35AM' }, { start_time: '9:00AM' }, {end_time: '4:30PM'} ],
    #     tue: { start_time: '11:30PM', end_time: '12:00AM' },
    #     fri: { start_time: '7:00PM', end_time: '9:00PM' },
    #   }
    def initialize(
      start_date:,
      end_date: nil,
      time_blocks: nil,
      day_of_week_time_blocks: nil,
      limit: nil,
      exclusion_dates: nil,
      time_zone: 'Etc/UTC',
      days_of_week: nil,
      nth_day_of_week_in_month: nil,
      days_of_month: nil,
      weeks_of_month: nil,
      months: nil
    )

      @time_zone = TZInfo::Timezone.get(time_zone)
      @days_of_week = days_of_week
      @nth_day_of_week_in_month = nth_day_of_week_in_month
      @days_of_month = days_of_month
      @weeks_of_month = weeks_of_month
      @months = months
      @time_blocks = time_blocks
      @day_of_week_time_blocks = day_of_week_time_blocks
      @start_date = start_date.is_a?(String) ? Date.parse(start_date) : start_date
      @end_date = end_date.is_a?(String) ? Date.parse(end_date) : end_date
      @limit = limit
      @exclusion_dates = if exclusion_dates && !exclusion_dates.empty?
                           exclusion_dates.map { |ed| Date.parse(ed) }
                         end
      validate!
    end

    # @return [Array<Hash<DateTime>>]
    #   Ex: [
    #     {
    #       start: #<DateTime>,
    #       end: #<DateTime>,
    #     }
    #   ]
    def generate
      initialize_looping_variables!
      while @keep_generating
        if should_add_time_blocks_from_current_date?
          add_time_blocks_from_current_date!
        end
        advance_current_date_and_check_if_reached_end_date
      end
      @output
    end

    private

    def validate!
      unless @day_of_week_time_blocks || @time_blocks
        raise "`day_of_week_time_blocks` or `time_blocks` need to be provided"
      end

      if @days_of_week && @day_of_week_time_blocks
        raise "`days_of_week` and `day_of_week_time_blocks` are both provided, which leads to ambiguity.  Please use only one of these parameters."
      end

      if @weeks_of_month
        @weeks_of_month.each do |wom|
          unless wom.is_a?(Integer) && wom.between?(1, 5)
            raise "weeks_of_month must be an array of integers between 1 and 5"
          end
        end
      end

      # days of week are valid
      if @days_of_week
        @days_of_week.each do |day|
          unless VALID_DAYS_OF_WEEK.include?(day.to_s)
            raise "#{day} is not valid day of week format.  Must be: #{VALID_DAYS_OF_WEEK}"
          end
        end
      end

      if @nth_day_of_week_in_month
        @nth_day_of_week_in_month.keys.each do |day|
          unless VALID_DAYS_OF_WEEK.include?(day.to_s)
            raise "#{day} is not valid day of week format.  Must be: #{VALID_DAYS_OF_WEEK}"
          end
        end
          @nth_day_of_week_in_month.each do |k,v|
            unless v.is_a?(Array)
              raise "nth_day_of_week_in_month parameter is invalid.  Please look at the README for examples."
            end
            v.each do |num|
              unless [-1,1,2,3,4,5].include?(num)
                raise "nth_day_of_week_in_month parameter is invalid. Please look at the README for examples. "
              end
            end
          end
      end

      if @days_of_week && @nth_day_of_week_in_month
        # If both `days_of_week` and `nth_day_of_week_in_month` are provided for the same days-of-the-week, then it is ambiguous.  (ie. I want this timeslot for every Monday, but also only for the first Mondays, well which one is it?)
        overlapping_days = @days_of_week & @nth_day_of_week_in_month.keys.map(&:to_s)
        unless overlapping_days.empty?
          raise "#{overlapping_days} is specified in both `days_of_week` and also `nth_day_of_week_in_month`, which leads to ambiguity.  Pleasee look at the README for examples."
        end
      end

      if @day_of_week_time_blocks
        @day_of_week_time_blocks.keys.each do |d|
          unless VALID_DAYS_OF_WEEK.include?(d.to_s)
            raise "#{d} is not a valid day of week format. Must be #{VALID_DAYS_OF_WEEK}"
          end
        end
      end

      if @days_of_month
        @days_of_month.each do |dom|
          unless dom.is_a?(Integer) && dom.between?(1,31)
            raise 'days_of_months must be array of integers between 1 and 31'
          end
        end
      end

      if @months
        @months.each do |mon|
          unless mon.is_a?(Integer) && mon.between?(1, 12)
            raise 'months must be array of integers between 1 and 12'
          end
        end
      end

      unless( @limit || @end_date)
        raise "Either `limit` or `end_date` must be provided"
      end
    end

    def day_of_week_long_to_short(dow)
      {
        "Monday" => "mon",
        "Tuesday" => "tue",
        "Wednesday" => "wed",
        "Thursday" => "thu",
        "Friday" => "fri",
        "Saturday" => "sat",
        "Sunday" => "sun",
      }[dow]
    end

    # @param [String] time_str
    #   Ex: '9:00AM'
    # @param [Date] date
    def time_str_to_object(date, time_str)
      time = Time.strptime(time_str, "%I:%M%p")
      date_time = DateTime.new(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.min,
        time.sec,
      )
      @time_zone.local_to_utc(date_time).new_offset(@time_zone.current_period.offset.utc_total_offset)
    end

    # @param [Date] date
    # @return [Boolean]
    #   Whether or not the date is excluded
    def excluded_date?(date)
      return false unless @exclusion_dates

      @exclusion_dates.each do |ed|
        return true if date == ed
      end

      false
    end

    # Variables which manage flow of looping through time and generating slots
    def initialize_looping_variables!
      @output = []
      @current_date = @start_date
      @current_count = 0
      @keep_generating = true
    end

    # @param [Hash] time_block
    #  Ex:
    #  {
    #    start_time: "9:00AM",
    #    start_time: "10:00AM",
    #  }
    #  Generates time block but also checks if we should stop generating
    def append_to_output_and_check_limit(time_block)
      @output << {
        start: time_str_to_object(@current_date, time_block[:start_time]),
        end: time_str_to_object(@current_date, time_block[:end_time])
      }

      # increment count, if `limit` is used to stop generating
      @current_count = @current_count + 1
      if @limit && @current_count == @limit
        @keep_generating = false
        throw :done
      end
    end

    def advance_current_date_and_check_if_reached_end_date
      @current_date = @current_date + 1

      if @end_date && (@current_date > @end_date)
        @keep_generating = false
      end

      # kill switch to stop infinite loop when `limit` is used but
      # there is bug, or badly specified rules.  If @current_date goes into a
      # 1000 years in the future, but no dates have been generated yet, this is
      # most likely an infinite loop situation, and needs to be killed.
      if @limit && ((@current_date - @start_date).to_i > 365000) && @output.empty?
        raise "No end condition detected, causing infinite loop.  Please check rules/conditions or raise github issue for potential bug fixed"
      end
    end

    # @return [Boolean]
    #   Should time blocks be added based on the current_date?
    def should_add_time_blocks_from_current_date?
      # return false if current_date is explicitly excluded
      if @exclusion_dates
        return false if @exclusion_dates.include?(@current_date)
      end

      # If weeks_of_months are specified but not satisified, return false
      if @weeks_of_month
        return false unless @weeks_of_month.include?(@current_date.week_of_month)
      end

      # If months are specified, but current_date does not satisfy months,
      # return false
      if @months
        return false unless @months.include?(@current_date.month)
      end

      # If days of months are specified, but current_date does not satisfy it,
      # return false
      if @days_of_month
        return false unless @days_of_month.include?(@current_date.day)
      end

      # The following conditions depend on the day-of-week of current_date.
      day_of_week = day_of_week_long_to_short(@current_date.strftime("%A"))

      # If days of week are specified, but current_date does not satisfy it,
      # return false
      if @days_of_week
        return false unless @days_of_week.include?(day_of_week)
      end

      if @day_of_week_time_blocks
        dowtb = @day_of_week_time_blocks[day_of_week.to_sym]
        return false if dowtb.nil?
        return false if dowtb.empty?
      end

      if @nth_day_of_week_in_month
        # If the day of week is specified in nth_day_of_week_in_month,
        # we need to investigate it whether or not to exclude it.
        if @nth_day_of_week_in_month[day_of_week.to_sym]
          n_occurence_of_day_of_week_in_month = ((@current_date.day - 1) / 7) + 1
          # -1 is a special case and requires extra-math
          if @nth_day_of_week_in_month[day_of_week.to_sym].include?(-1)
            # We basically want to convert the -1 into its 'positive-equivalent` in this month, and compare it with that.
            # For example, in June 2024, the Last Friday is also the 4th Friday.  So in that case, we convert the -1 into a 4.
            positivized_indices = @nth_day_of_week_in_month[day_of_week.to_sym].map { |indx| positivize_index(indx, day_of_week) }
            return positivized_indices.include?(n_occurence_of_day_of_week_in_month)
          else
            return @nth_day_of_week_in_month[day_of_week.to_sym].include?(n_occurence_of_day_of_week_in_month)
          end
        else
          # if day-of-week was not specified in nth_day_of_week_in_month,
          # it could have been specified in either `days_of_week` or `day_of_week_time_blocks and we unfortunately need to re-check those here. I cant think of a way to further DRY-it up.
          return false unless @days_of_weeks || @day_of_week_time_blocks
          if @day_of_weeks
            return false unless @days_of_week.include?(day_of_week)
          end

          if @day_of_week_time_blocks
            dowtb = @day_of_week_time_blocks[day_of_week.to_sym]
            return false if dowtb.nil?
            return false if dowtb.empty?
          end
        end
      end

      # Otherwise, return true
      true
    end

    def add_time_blocks_from_current_date!
      if @day_of_week_time_blocks
        day_of_week = day_of_week_long_to_short(@current_date.strftime("%A"))
        time_blocks = @day_of_week_time_blocks[day_of_week.to_sym]
        catch :done do
          time_blocks.each do |tb|
            append_to_output_and_check_limit(tb)
          end
        end
      elsif @time_blocks
        catch :done do
          @time_blocks.each do |tb|
            append_to_output_and_check_limit(tb)
          end
        end
      end
    end

    # What is the positive index of the last day-of-week for the given month-year?
    # For example, the last Friday in June 2024 is also the nth Friday.  What is this n?
    # @return [Integer]
    def positivize_index(indx, day_of_week)
      # If index is already positive, just return it
      return indx if indx > 0

      # get last_day_of month
      month = @current_date.month
      year = @current_date.year
      last_date = Date.new(year, month, -1)

      # walk backwords until you get to the right day of the week
      while day_of_week_long_to_short(last_date.strftime("%A")) != day_of_week
        last_date = last_date - 1
      end

      ((last_date.day - 1) / 7) + 1
    end
  end
end
