require "periodoxical/version"
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
    # @param [Integer] limit
    #   How many date times to generate.  To be used when `end_date` is nil.
    # @param [Aray<String>] exclusion_dates
    #   Dates to be excluded when generating the time blocks
    #   Ex: ['2024-06-10', '2024-06-14']
    # @param [Hash<Hash>] day_of_week_time_blocks
    #   To be used when hours are different between days of the week
    #   Ex: {
    #     mon: [{ start_time: '10:15AM', end_time: '11:35AM' }, { start_time: '9:00AM' }, {end_time: '4:30PM'} ],
    #     tue: { start_time: '11:30PM', end_time: '12:00AM' },
    #     fri: { start_time: '7:00PM', end_time: '9:00PM' },
    #   }
    def initialize(time_zone: 'Etc/UTC', days_of_week: nil,
                   start_date:, end_date: nil, time_blocks: nil, day_of_week_time_blocks: nil, limit: nil, exclusion_dates: nil)
      @time_zone = TZInfo::Timezone.get(time_zone)
      @days_of_week = days_of_week
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
      if @days_of_week && @time_blocks
        generate_when_same_time_blocks_for_all_days
      elsif @day_of_week_time_blocks
        generate_when_different_time_blocks_between_days
      end
    end

    private

    def generate_when_different_time_blocks_between_days
      times_output = []
      current_date = @start_date
      current_count = 0
      keep_generating = true
      while keep_generating
        day_of_week = day_of_week_long_to_short(current_date.strftime("%A"))
        if @day_of_week_time_blocks[day_of_week.to_sym] && !excluded_date?(current_date)
          time_blocks = @day_of_week_time_blocks[day_of_week.to_sym]
          time_blocks.each do |tb|
            times_output << {
              start: time_str_to_object(current_date, tb[:start_time]),
              end: time_str_to_object(current_date, tb[:end_time])
            }
            current_count = current_count + 1
            if @limit && current_count == @limit
              keep_generating = false
              break
            end
          end
        end
        current_date = current_date + 1
        if @end_date && (current_date > @end_date)
          keep_generating = false
        end
      end
      times_output
    end

    def generate_when_same_time_blocks_for_all_days 
      times_output = []
      current_date = @start_date
      current_count = 0
      keep_generating = true
      while keep_generating
        day_of_week = day_of_week_long_to_short(current_date.strftime("%A"))
        if @days_of_week.include?(day_of_week) && !excluded_date?(current_date)
          @time_blocks.each do |tb|
            times_output << {
              start: time_str_to_object(current_date, tb[:start_time]),
              end: time_str_to_object(current_date, tb[:end_time])
            }
            current_count = current_count + 1
            if @limit && current_count == @limit
              keep_generating = false
              break
            end
          end
        end
        current_date = current_date + 1

        if @end_date && (current_date > @end_date)
          keep_generating = false
        end
      end
      times_output
    end

    def validate!
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

      unless (@days_of_week && @time_blocks) || (@day_of_week_time_blocks)
        raise "Need to provide either `days_of_week` and `time_blocks` or `day_of_week_time_blocks`"
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

    # @param [Date] current_date
    # @return [Boolean]
    #   Whether or not the date is excluded
    def excluded_date?(current_date)
      return false unless @exclusion_dates

      @exclusion_dates.each do |ed|
        return true if current_date == ed
      end

      false
    end
  end
end
