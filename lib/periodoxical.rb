require "periodoxical/version"
require "periodoxical/validation"
require "periodoxical/helpers"
require "date"
require "time"
require "tzinfo"

module Periodoxical
  class << self
    def generate(**opts)
      Core.new(**opts).generate
    end
  end

  class Core
    include Periodoxical::Validation
    include Periodoxical::Helpers
    # @param [String] time_zone
    #   Ex: 'America/Los_Angeles', 'America/Chicago',
    #   TZInfo::DataTimezone#name from the tzinfo gem (https://github.com/tzinfo/tzinfo)
    # @param [Date, String] starting_from
    # @param [Date, String] ending_at
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
    #   How many date times to generate.  To be used when `ending_at` is nil.
    # @param [Aray<String>] exclusion_dates
    #   Dates to be excluded when generating the time blocks
    #   Ex: ['2024-06-10', '2024-06-14']
    # @param [Aray<Hash>] exclusion_times
    #   Timeblocks to be excluded when generating the time blocks if there is conflict (ie. overlap)
    #   Ex: [
    #         {
    #           start: '2024-06-10T10:30:00-07:00',
    #           end: '2024-06-10T11:30:00-07:00'
    #         },
    #         {
    #           start: '2024-06-10T14:30:00-07:00',
    #           end: '2024-06-10T15:30:00-07:00'
    #         },
    #       ]
    #
    # @param [Hash<Array<Hash>>] day_of_week_time_blocks
    #   To be used when hours are different between days of the week
    #   Ex: {
    #     mon: [{ start_time: '10:15AM', end_time: '11:35AM' }, { start_time: '9:00AM' }, {end_time: '4:30PM'} ],
    #     tue: { start_time: '11:30PM', end_time: '12:00AM' },
    #     fri: { start_time: '7:00PM', end_time: '9:00PM' },
    #   }
    # @param [Integer] duration
    #   Splits the time_blocks into this duration (in minutes). For example, if time_block is 9:00AM - 10:00AM,
    #   and duration is 20 minutes.  It creates 3 timeblocks of:
    #     - 9:00AM - 9:20AM
    #     - 9:20AM - 9:40AM
    #     - 9:40AM - 10:00AM
    # @param [Symbol] ambiguous_time
    #   How to resolve DST fall-back ambiguous local times (e.g. 01:30 occurs twice).
    #   Allowed: :first (daylight time), :last (standard time), :raise (default).
    # @param [Symbol] gap_strategy
    #   How to handle DST spring-forward missing local times (e.g. 02:30 does not exist).
    #   Allowed: :advance (shift forward), :skip (omit block), :raise (default).
    # @param [Integer] gap_shift_minutes
    #   Minutes to advance when gap_strategy is :advance. Default: 60.
    def initialize(
      starting_from:,
      ending_at: nil,
      time_blocks: nil,
      day_of_week_time_blocks: nil,
      limit: nil,
      exclusion_dates: nil,
      exclusion_times: nil,
      time_zone: 'Etc/UTC',
      days_of_week: nil,
      nth_day_of_week_in_month: nil,
      days_of_month: nil,
      duration: nil,
      months: nil,
      ambiguous_time: :raise,
      gap_strategy: :raise,
      gap_shift_minutes: 60
    )

      @time_zone = TZInfo::Timezone.get(time_zone)
      @ambiguous_time = ambiguous_time
      @gap_strategy = gap_strategy
      @gap_shift_minutes = gap_shift_minutes
      if days_of_week.is_a?(Array)
        @days_of_week = deep_symbolize_keys(days_of_week)
      elsif days_of_week.is_a?(Hash)
        @days_of_week_with_alternations = deep_symbolize_keys(days_of_week)
      end
      @nth_day_of_week_in_month = deep_symbolize_keys(nth_day_of_week_in_month)
      @days_of_month = days_of_month
      @months = months
      @time_blocks = deep_symbolize_keys(time_blocks)
      @day_of_week_time_blocks = deep_symbolize_keys(day_of_week_time_blocks)
      @starting_from = date_object_from(starting_from)
      @ending_at = date_object_from(ending_at)
      @limit = limit

      if duration
        unless duration.is_a?(Integer)
          raise "duration must be an integer"
        else
          @duration = duration
        end
      end
      @exclusion_dates = if exclusion_dates && !exclusion_dates.empty?
                           exclusion_dates.map { |ed| Date.parse(ed) }
                         end
      @exclusion_times = if exclusion_times
                           deep_symbolize_keys(exclusion_times).map do |et|
                             { start: DateTime.parse(et[:start]), end: DateTime.parse(et[:end]) }
                           end
                         end
      validate!
    end

    # @return [Array<Hash<DateTime>>]
    #   Ex: [
    #     {
    #       start: #<DateTime>,
    #       end: #<DateTime>,
    #     },
    #     {
    #       start: #<DateTime>,
    #       end: #<DateTime>,
    #     },
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

    # @param [String] time_str
    #   Ex: '9:00AM'
    # @return [Date] date
    #
    # Converts a local date and time string to UTC and returns a DateTime with the
    # timezone offset corresponding to the zone period at that instant.
    # Handles DST transitions explicitly:
    #  - Ambiguous (fall-back) times resolved via `@ambiguous_time`.
    #  - Missing (spring-forward) times handled via `@gap_strategy` and `@gap_shift_minutes`.
    def time_str_to_object(date, time_str)
      time = Time.strptime(time_str, '%I:%M%p')
      date_time = DateTime.new(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.min,
        time.sec,
      )
      utc_time = begin
        @time_zone.local_to_utc(date_time) do |periods|
          case @ambiguous_time
          when :first
            periods.first
          when :last
            periods.last
          when :raise
            raise TZInfo::AmbiguousTime, date_time.to_s
          else
            periods.last
          end
        end
      rescue TZInfo::AmbiguousTime
        case @ambiguous_time
        when :first
          @time_zone.local_to_utc(date_time) { |periods| periods.first }
        when :last
          @time_zone.local_to_utc(date_time) { |periods| periods.last }
        else
          raise
        end
      rescue TZInfo::PeriodNotFound
        case @gap_strategy
        when :advance
          step = Rational(@gap_shift_minutes, 24 * 60)
          shifted = date_time
          attempts = 0
          begin
            shifted += step
            attempts += 1
            raise TZInfo::PeriodNotFound if attempts > 240
            @time_zone.local_to_utc(shifted)
          rescue TZInfo::PeriodNotFound
            retry
          end
        when :skip
          return nil
        else
          raise
        end
      end

      period_at_utc = @time_zone.period_for_utc(utc_time)
      utc_time.new_offset(period_at_utc.offset.utc_total_offset)
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
      if @starting_from.is_a?(DateTime)
        @current_date = @starting_from.to_date
      else
        @current_date = @starting_from
      end
      @current_day_of_week = day_of_week_long_to_short(@current_date.strftime("%A"))
      @current_count = 0
      @keep_generating = true
      # When there are alternations in days of week
      # (ie. every other Monday, every 3rd Thursday, etc).
      # We keep running tally of day_of_week counts and use modulo-math to pick out
      # every n-th one.
      if @days_of_week_with_alternations
        @days_of_week_running_tally = {
          mon: 0,
          tue: 0,
          wed: 0,
          thu: 0,
          fri: 0,
          sat: 0,
          sun: 0,
        }
      end
    end

    # @param [Hash] time_block
    #  Ex:
    #  {
    #    start_time: "9:00AM",
    #    start_time: "10:00AM",
    #  }
    #  Generates time block but also checks if we should stop generating
    def append_to_output_and_check_limit(time_block)
      strtm = time_str_to_object(@current_date, time_block[:start_time])
      endtm = time_str_to_object(@current_date, time_block[:end_time])

      return if strtm.nil? || endtm.nil?

      if @duration
        split_by_duration_and_append(strtm, endtm)
      else
        # Check if this particular time is conflicts with any times from `exclusion_times`.
        return if before_starting_from_or_after_ending_at?(time_block)
        return if overlaps_with_an_excluded_time?({ start: strtm, end: endtm })

        @output << {
          start: strtm,
          end: endtm
        }
        increment_and_check_limit
      end
    end

    # increment count, if `limit` is used to stop generating
    def increment_and_check_limit
      return unless @limit

      @current_count += 1
      return if @current_count < @limit

      @keep_generating = false
      throw :done
    end

    def advance_current_date_and_check_if_reached_end_date
      @current_date = @current_date + 1

      @current_day_of_week = day_of_week_long_to_short(@current_date.strftime("%A"))

      if @ending_at && (@current_date > @ending_at)
        @keep_generating = false
      end

      # kill switch to stop infinite loop when `limit` is used but
      # there is bug, or poorly specified rules.  If @current_date goes into
      # 1000 years in the future, but still no dates have been generated yet, this is
      # most likely an infinite loop situation, and needs to be killed.
      if @limit && ((@current_date - @starting_from).to_i > 365000) && @output.empty?
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
        return false unless @days_of_week.include?(@current_day_of_week)
      end

      if @days_of_week_with_alternations
        # current_date is not specified in days_of_week, so skip it
        return false if @days_of_week_with_alternations[@current_day_of_week.to_sym].nil?

        alternating_spec = @days_of_week_with_alternations[@current_day_of_week.to_sym]

        # In the { every: true } case, we don't check the alternations logic, we just add it.
        unless alternating_spec[:every]
          # We are now specifying every other nth occurrence (ie. every 2nd Tuesday, every 3rd Wednesday)
          alternating_frequency = alternating_spec[:every_other_nth]

          unless (@days_of_week_running_tally[@current_day_of_week.to_sym] % alternating_frequency) == 0
            # If day-of-week alternations are present, we need to keep track of day-of-weeks
            # we have encountered and added or would have added so far.
            update_days_of_week_running_tally!

            return false
          end
          update_days_of_week_running_tally!
        end
      end

      if @day_of_week_time_blocks
        dowtb = @day_of_week_time_blocks[@current_day_of_week.to_sym]
        return false if dowtb.nil?
        return false if dowtb.empty?
      end

      if @nth_day_of_week_in_month
        # If the day of week is specified in nth_day_of_week_in_month,
        # we need to investigate it whether or not to exclude it.
        if @nth_day_of_week_in_month[@current_day_of_week.to_sym]
          n_occurence_of_day_of_week_in_month = ((@current_date.day - 1) / 7) + 1
          # -1 is a special case and requires extra-math
          if @nth_day_of_week_in_month[@current_day_of_week.to_sym].include?(-1)
            # We basically want to convert the -1 into its 'positive-equivalent` in this month, and compare it with that.
            # For example, in June 2024, the Last Friday is also the 4th Friday.  So in that case, we convert the -1 into a 4.
            positivized_indices = @nth_day_of_week_in_month[@current_day_of_week.to_sym].map { |indx| positivize_index(indx, @current_day_of_week) }
            return positivized_indices.include?(n_occurence_of_day_of_week_in_month)
          else
            return @nth_day_of_week_in_month[@current_day_of_week.to_sym].include?(n_occurence_of_day_of_week_in_month)
          end
        else
          return false
        end
      end

      # The default return true is really only needed to support this use-case:
      # Periodoxical.generate(
      #   time_zone: 'America/Los_Angeles',
      #   time_blocks: [
      #     {
      #       start_time: '9:00AM',
      #       end_time: '10:30AM'
      #     },
      #   ],
      #   starting_from: '2024-05-23',
      #   ending_at: '2024-05-27',
      # )
      # where if we don't specify any date-of-week/month constraints, we return all consecutive dates.
      # In the future, if we don't support this case, we can use `false` as the return value.
      true
    end

    def add_time_blocks_from_current_date!
      if @day_of_week_time_blocks
        time_blocks = @day_of_week_time_blocks[@current_day_of_week.to_sym]
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

    def update_days_of_week_running_tally!
      @days_of_week_running_tally[@current_day_of_week.to_sym] = @days_of_week_running_tally[@current_day_of_week.to_sym] + 1
    end

    # @return [Boolean]
    #   Used only when `starting_from` and `ending_at` are instances of DateTime
    #   instead of Date, requiring more precision, calculation.
    def before_starting_from_or_after_ending_at?(time_block)
      return false unless @starting_from.is_a?(DateTime) || @ending_at.is_a?(DateTime)

      if @starting_from.is_a?(DateTime)
        start_time = time_str_to_object(@current_date, time_block[:start_time])
        return false if start_time.nil?

        # If the candidate time block is starting earlier than @starting_from, we want to skip it
        return true if start_time < @starting_from
      end

      if @ending_at.is_a?(DateTime)
        end_time = time_str_to_object(@current_date, time_block[:end_time])
        return false if end_time.nil?

        # If the candidate time block is ending after @ending_at, we want to skip it
        return true if end_time > @ending_at
      end

      false
    end

    # @param [Hash] time_block
    # Ex:
    #   {
    #     start: #<DateTime>,
    #     end: #<DateTime>,
    #   }
    # @return [Boolean]
    #   Whether or not the given `time_block` in the @current_date and
    #   @time_zone overlaps with the times in `exclusion_times`.
    def overlaps_with_an_excluded_time?(tm_blck)
      return false unless @exclusion_times

      @exclusion_times.each do |exclusion_timeblock|
        return true if overlap?(
          exclusion_timeblock,
          tm_blck
        )
      end

      false
    end

    def split_by_duration_and_append(strtm, endtm)
      delta = Rational(@duration, 24 * 60)
      si = strtm
      ei = strtm + delta
      while ei <= endtm
        unless overlaps_with_an_excluded_time?({ start: si, end: ei })
          @output << {
            start: si,
            end: ei
          }
          increment_and_check_limit
        end
        si += delta
        ei += delta
      end
    end
  end
end
