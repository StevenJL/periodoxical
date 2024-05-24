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
    # @param [Date] start_date
    # @param [Date] end_date
    # @param [Array<String>, nil] days_of_week
    #   Days of the week to generate the times for, if nil, then times are generated
    #   for every day.
    #   Ex: %w(mon tue wed sat)
    # @param [Integer] limit
    #   How many date times to generate.  To be used when `end_date` is nil.
    # @param [Hash<Hash>] day_of_week_hours
    #   To be used when hours are different between days of the week
    #   Ex: {
    #     mon: [{ start_time: '10:15AM', end_time: '11:35AM' }, { start_time: '9:00AM' }, {end_time: '4:30PM'} ],
    #     tue: { start_time: '11:30PM', end_time: '12:00AM' },
    #     fri: { start_time: '7:00PM', end_time: '9:00PM' },
    #   }
    def initialize(time_zone: 'Etc/UTC', days_of_week: nil,
                   start_date:, end_date:, time_blocks: nil, day_of_week_hours: nil, limit: nil)
      @time_zone = TZInfo::Timezone.get(time_zone)
      @days_of_week = days_of_week
      @time_blocks = time_blocks
      @day_of_week_hours = day_of_week_hours
      @start_date = start_date
      @end_date = end_date
      @limit = limit
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
        generate_from_days_of_week_time_blocks
      end
    end

    private

    def generate_from_days_of_week_time_blocks
      times = []
      current_date = @start_date
      while current_date <= @end_date
        day_of_week = day_of_week_long_to_short(current_date.strftime("%A"))
        if @days_of_week.include?(day_of_week)
          @time_blocks.each do |tb|
            times << {
              start: time_str_to_object(current_date, tb[:start_time]),
              end: time_str_to_object(current_date, tb[:end_time])
            }
          end
        end
        current_date = current_date + 1
      end
      times
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

      if @day_of_week_hours
        @day_of_week_hours.keys.each do |d|
          unless VALID_DAYS_OF_WEEK.include?(d)
            raise "#{d} is not a valid day of week format. Must be #{VALID_DAYS_OF_WEEK}"
          end
        end
      end

      unless (@days_of_week && @start_time && @end_time) || (@day_of_week_hours)
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
  end
end
