module Periodoxical
  module Helpers
    def deep_symbolize_keys(obj)
      return unless obj

      case obj
      when Hash
        obj.each_with_object({}) do |(key, value), result|
          symbolized_key = key.to_sym rescue key
          result[symbolized_key] = deep_symbolize_keys(value)
        end
      when Array
        obj.map { |e| deep_symbolize_keys(e) }
      else
        obj
      end
    end

    # @param [Hash] time_block_1, time_block_2
    #  Ex: {
    #    start: #<DateTime>,
    #    end: #<DateTime>,
    #  }
    def overlap?(time_block_1, time_block_2)
      tb_1_start = time_block_1[:start]
      tb_1_end = time_block_1[:end]
      tb_2_start = time_block_2[:start]
      tb_2_end = time_block_2[:end]

      # Basicall overlap is when one starts before the other has ended
      return true if tb_1_end > tb_2_start && tb_1_end < tb_2_end
      # By symmetry
      return true if tb_2_end > tb_1_start && tb_2_end < tb_1_end

      false
    end

    def date_object_from(dt)
      return unless dt
      return dt if dt.is_a?(Date) || dt.is_a?(DateTime)

      if dt.is_a?(String)
        return Date.parse(dt) if /\A\d{4}-(0?[1-9]|1[0-2])-(0?[1-9]|[12]\d|3[01])\z/ =~ dt

        if /\A\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(\.\d+)?(Z|[+-][01]\d:[0-5]\d)?\z/ =~ dt
          # convert to DateTime object
          dt = DateTime.parse(dt)
          # convert to given time_zone
          return dt.to_time.localtime(@time_zone.utc_offset).to_datetime
        end

        raise "Could not parse date/datetime string #{dt}.  Please README for examples."
      else
        raise "Invalid argument: #{dt}"
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
  end
end
