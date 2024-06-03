module Periodoxical
  module Validation
    VALID_DAYS_OF_WEEK = %w[mon tue wed thu fri sat sun].freeze
    def validate!
      unless @day_of_week_time_blocks || @time_blocks
        raise "`day_of_week_time_blocks` or `time_blocks` need to be provided"
      end

      if (@days_of_week || @days_of_week_with_alternations) && @day_of_week_time_blocks
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

      if @days_of_week_with_alternations
        @days_of_week_with_alternations.each do |dow, every_other|
          unless VALID_DAYS_OF_WEEK.include?(dow.to_s)
            raise "#{dow} is not valid day of week format.  Must be: #{VALID_DAYS_OF_WEEK}"
          end
          unless every_other.is_a?(Hash)
            raise "days_of_week parameter is not used correctly.  Please look at examples in README."
          end
          unless every_other[:every] || every_other[:every_other_nth]
            raise "days_of_week parameter is not used correctly.  Please look at examples in README."
          end
          if every_other[:every_other_nth]
            unless every_other[:every_other_nth].is_a?(Integer)
              raise "days_of_week parameter is not used correctly.  Please look at examples in README."
            end

            unless every_other[:every_other_nth] > 1
              raise "days_of_week parameter is not used correctly.  Please look at examples in README."
            end
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

      if @nth_day_of_week_in_month && (@days_of_week || @days_of_week_with_alternations || @day_of_week_time_blocks)
        raise "nth_day_of_week_in_month parameter cannot be used in combination with `days_of_week` or `day_of_week_time_blocks`.  Please look at the README for examples."
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
  end
end
