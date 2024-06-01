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
      days_of_month: nil,
      weeks_of_month: nil,
      months: nil
    )

      @time_zone = TZInfo::Timezone.get(time_zone)
      @days_of_week = days_of_week
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

      # If days of week are specified, but current_date does not satisfy it,
      # return false
      if @days_of_week
        day_of_week = day_of_week_long_to_short(@current_date.strftime("%A"))
        return false unless @days_of_week.include?(day_of_week)
      end

      if @day_of_week_time_blocks
        day_of_week = day_of_week_long_to_short(@current_date.strftime("%A"))
        dowtb = @day_of_week_time_blocks[day_of_week.to_sym]
        return false if dowtb.nil?
        return false if dowtb.empty?
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
  end
end
