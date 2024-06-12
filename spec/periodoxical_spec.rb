require "pry"
require "date"

RSpec.describe Periodoxical do
  def human_readable(time_blocks)
    timezone = TZInfo::Timezone.get('America/Los_Angeles')
    time_blocks_str = time_blocks.map do |time_block|
      start_time = time_block[:start]
      end_time = time_block[:end]
      start_time_converted = timezone.utc_to_local(start_time.new_offset(0))
      end_time_converted = timezone.utc_to_local(end_time.new_offset(0))
      {
        start: start_time_converted.strftime('%Y-%m-%d %H:%M:%S %z'),
        end: end_time_converted.strftime('%Y-%m-%d %H:%M:%S %z'),
      }
    end
  end

  it "has a version number" do
    expect(Periodoxical::VERSION).not_to be nil
  end

  describe '.generate' do
    context 'validation' do
      context 'when no time_blocks or day_of_week_time_blocks is provided' do
        subject do
          Periodoxical.generate(
            time_zone: 'America/Los_Angeles',
            starting_from: '2024-05-23',
            ending_at: '2024-05-27',
          )
        end

        it 'raises error' do
          expect { subject }.to raise_error
        end
      end
    end

    context 'when only time_blocks are provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          time_blocks: [
            {
              start_time: '9:00AM',
              end_time: '10:30AM'
            },
          ],
          starting_from: '2024-05-23',
          ending_at: '2024-05-27',
        )
      end

      it 'generates correct time blocks' do
        time_blocks = human_readable(subject)

        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-05-23 09:00:00 -0700",
              :end=>"2024-05-23 10:30:00 -0700",
            },
            {
              :start=>"2024-05-24 09:00:00 -0700",
              :end=>"2024-05-24 10:30:00 -0700"
            },
            {
              :start=>"2024-05-25 09:00:00 -0700",
              :end=>"2024-05-25 10:30:00 -0700"
            },
            {
              :start=>"2024-05-26 09:00:00 -0700",
              :end=>"2024-05-26 10:30:00 -0700"
            },
            {
              :start=>"2024-05-27 09:00:00 -0700",
              :end=>"2024-05-27 10:30:00 -0700"
            }
          ]
        )
      end
    end

    context 'when iso8601 and DateTime time range is provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          time_blocks: [
            {
              start_time: '9:00AM',
              end_time: '10:30AM'
            },
          ],
          starting_from: '2024-05-23T09:30:00-07:00',
          ending_at: '2024-05-27T10:00:00-07:00',
        )
      end

      it 'returns the correct time blocks' do
        time_blocks = human_readable(subject)

        expect(time_blocks).to eq(
           [
             {
               :start=>"2024-05-24 09:00:00 -0700",
               :end=>"2024-05-24 10:30:00 -0700"
             },
             {
               :start=>"2024-05-25 09:00:00 -0700",
               :end=>"2024-05-25 10:30:00 -0700"
             },
             {
               :start=>"2024-05-26 09:00:00 -0700",
               :end=>"2024-05-26 10:30:00 -0700"
             }
           ]
        )
      end
    end

    context 'when using days_of_weeks and time_blocks' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          days_of_week: %w[mon wed thu],
          time_blocks: [
            {
              start_time: '9:00AM',
              end_time: '10:30PM'
            },
            {
              start_time: '2:00PM',
              end_time: '2:30PM'
            }
          ],
          starting_from: '2024-05-23',
          ending_at: '2024-06-12',
        )
      end

      it "generates all the times 9:00AM to 10:30PM, 2:00PM to 2:30PM on Mondays, Wednesdays, and Thursdays, between May 23, 2024 and June 12, 2024" do
        time_blocks = human_readable(subject)
        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-05-23 09:00:00 -0700",
              :end=>"2024-05-23 22:30:00 -0700"
            },
            {
              :start=>"2024-05-23 14:00:00 -0700",
              :end=>"2024-05-23 14:30:00 -0700"
            },
            {
              :start=>"2024-05-27 09:00:00 -0700",
              :end=>"2024-05-27 22:30:00 -0700"
            },
            {
              :start=>"2024-05-27 14:00:00 -0700",
              :end=>"2024-05-27 14:30:00 -0700"
            },
            {
              :start=>"2024-05-29 09:00:00 -0700",
              :end=>"2024-05-29 22:30:00 -0700"
            },
            {
              :start=>"2024-05-29 14:00:00 -0700",
              :end=>"2024-05-29 14:30:00 -0700"
            },
            {
              :start=>"2024-05-30 09:00:00 -0700",
              :end=>"2024-05-30 22:30:00 -0700"
            },
            {
              :start=>"2024-05-30 14:00:00 -0700",
              :end=>"2024-05-30 14:30:00 -0700"
            },
            {
              :start=>"2024-06-03 09:00:00 -0700",
              :end=>"2024-06-03 22:30:00 -0700"
            },
            {
              :start=>"2024-06-03 14:00:00 -0700",
              :end=>"2024-06-03 14:30:00 -0700"
            },
            {
              :start=>"2024-06-05 09:00:00 -0700",
              :end=>"2024-06-05 22:30:00 -0700"
            },
            {
              :start=>"2024-06-05 14:00:00 -0700",
              :end=>"2024-06-05 14:30:00 -0700"
            },
            {
              :start=>"2024-06-06 09:00:00 -0700",
              :end=>"2024-06-06 22:30:00 -0700"
            },
            {
              :start=>"2024-06-06 14:00:00 -0700",
              :end=>"2024-06-06 14:30:00 -0700"
            },
            {
              :start=>"2024-06-10 09:00:00 -0700",
              :end=>"2024-06-10 22:30:00 -0700"
            },
            {
              :start=>"2024-06-10 14:00:00 -0700",
              :end=>"2024-06-10 14:30:00 -0700"
            },
            {
              :start=>"2024-06-12 09:00:00 -0700",
              :end=>"2024-06-12 22:30:00 -0700"
            },
            {
              :start=>"2024-06-12 14:00:00 -0700",
              :end=>"2024-06-12 14:30:00 -0700"
            },
          ]
        )
      end
    end

    context 'when using limit' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          days_of_week: %w[sun],
          time_blocks: [
            {
              start_time: '9:00AM',
              end_time: '10:30PM'
            },
            {
              start_time: '2:00PM',
              end_time: '2:30PM'
            }
          ],
          starting_from: Date.parse('2024-05-23'),
          limit: 5
        )
      end

      it "generates 5 all the times 9:00AM to 10:30PM, 2:00PM to 2:30PM on Sundays" do
        time_blocks = human_readable(subject)
        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-05-26 09:00:00 -0700",
              :end=>"2024-05-26 22:30:00 -0700"
            },
           {
             :start=>"2024-05-26 14:00:00 -0700",
             :end=>"2024-05-26 14:30:00 -0700"
           },
           {
             :start=>"2024-06-02 09:00:00 -0700",
             :end=>"2024-06-02 22:30:00 -0700"
           },
           {
             :start=>"2024-06-02 14:00:00 -0700",
             :end=>"2024-06-02 14:30:00 -0700"
           },
           {
             :start=>"2024-06-09 09:00:00 -0700",
             :end=>"2024-06-09 22:30:00 -0700"
           }
          ]
        )
      end
    end

    context 'when time blocks varies between days' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: Date.parse('2024-05-23'),
          ending_at: Date.parse('2024-06-12'),
          day_of_week_time_blocks: {
            mon: [
              { start_time: '8:00AM', end_time: '9:00AM' },
            ],
            wed: [
              { start_time: '10:45AM', end_time: '12:00PM' },
              { start_time: '2:00PM', end_time: '4:00PM' },
            ],
            thu: [
              { start_time: '2:30PM', end_time: '4:15PM' }
            ],
          }
        )
      end

      it 'generates correct time blocks' do
        time_blocks = human_readable(subject)

        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-05-23 14:30:00 -0700",
              :end=>"2024-05-23 16:15:00 -0700"
            },
            {
              :start=>"2024-05-27 08:00:00 -0700",
              :end=>"2024-05-27 09:00:00 -0700"
            },
            {
              :start=>"2024-05-29 10:45:00 -0700",
              :end=>"2024-05-29 12:00:00 -0700"
            },
            {
              :start=>"2024-05-29 14:00:00 -0700",
              :end=>"2024-05-29 16:00:00 -0700"
            },
            {
              :start=>"2024-05-30 14:30:00 -0700",
              :end=>"2024-05-30 16:15:00 -0700"
            },
            {
              :start=>"2024-06-03 08:00:00 -0700",
              :end=>"2024-06-03 09:00:00 -0700"
            },
            {
              :start=>"2024-06-05 10:45:00 -0700",
              :end=>"2024-06-05 12:00:00 -0700"
            },
            {
              :start=>"2024-06-05 14:00:00 -0700",
              :end=>"2024-06-05 16:00:00 -0700"
            },
            {
              :start=>"2024-06-06 14:30:00 -0700",
              :end=>"2024-06-06 16:15:00 -0700"
            },
            {
              :start=>"2024-06-10 08:00:00 -0700",
              :end=>"2024-06-10 09:00:00 -0700"
            },
            {
              :start=>"2024-06-12 10:45:00 -0700",
              :end=>"2024-06-12 12:00:00 -0700"
            },
            {
              :start=>"2024-06-12 14:00:00 -0700",
              :end=>"2024-06-12 16:00:00 -0700"
            }
          ]
        )
      end

      context 'when day_of_week_time_blocks parameter has string keys' do
        subject do
          Periodoxical.generate(
            time_zone: 'America/Los_Angeles',
            starting_from: Date.parse('2024-05-23'),
            ending_at: Date.parse('2024-06-12'),
            day_of_week_time_blocks: {
              'mon' => [
                { 'start_time' => '8:00AM', 'end_time' => '9:00AM' },
              ],
              'wed' => [
                { 'start_time' => '10:45AM', 'end_time' => '12:00PM' },
                { 'start_time' => '2:00PM', 'end_time' => '4:00PM' },
              ],
              'thu' => [
                { 'start_time' => '2:30PM', 'end_time' => '4:15PM' }
              ],
            }
          )
        end

        it 'generates correct time blocks' do
          time_blocks = human_readable(subject)

          expect(time_blocks).to eq(
            [
              {
                :start=>"2024-05-23 14:30:00 -0700",
                :end=>"2024-05-23 16:15:00 -0700"
              },
              {
                :start=>"2024-05-27 08:00:00 -0700",
                :end=>"2024-05-27 09:00:00 -0700"
              },
              {
                :start=>"2024-05-29 10:45:00 -0700",
                :end=>"2024-05-29 12:00:00 -0700"
              },
              {
                :start=>"2024-05-29 14:00:00 -0700",
                :end=>"2024-05-29 16:00:00 -0700"
              },
              {
                :start=>"2024-05-30 14:30:00 -0700",
                :end=>"2024-05-30 16:15:00 -0700"
              },
              {
                :start=>"2024-06-03 08:00:00 -0700",
                :end=>"2024-06-03 09:00:00 -0700"
              },
              {
                :start=>"2024-06-05 10:45:00 -0700",
                :end=>"2024-06-05 12:00:00 -0700"
              },
              {
                :start=>"2024-06-05 14:00:00 -0700",
                :end=>"2024-06-05 16:00:00 -0700"
              },
              {
                :start=>"2024-06-06 14:30:00 -0700",
                :end=>"2024-06-06 16:15:00 -0700"
              },
              {
                :start=>"2024-06-10 08:00:00 -0700",
                :end=>"2024-06-10 09:00:00 -0700"
              },
              {
                :start=>"2024-06-12 10:45:00 -0700",
                :end=>"2024-06-12 12:00:00 -0700"
              },
              {
                :start=>"2024-06-12 14:00:00 -0700",
                :end=>"2024-06-12 16:00:00 -0700"
              }
            ]
          )
        end
      end
    end

    context 'when exclusion_dates is provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-06-03',
          limit: 4,
          exclusion_dates: %w(2024-06-10),
          day_of_week_time_blocks: {
            mon: [
              { start_time: '8:00AM', end_time: '9:00AM' },
            ],
          }
        )
      end

      it 'returns the correct dates' do
        time_blocks = human_readable(subject)
        # All 8AM - 9AM Monday except the Monday of June 10, 2024
        expect(time_blocks).to eq(
          [
            {:start=>"2024-06-03 08:00:00 -0700", :end=>"2024-06-03 09:00:00 -0700"},
            {:start=>"2024-06-17 08:00:00 -0700", :end=>"2024-06-17 09:00:00 -0700"},
            {:start=>"2024-06-24 08:00:00 -0700", :end=>"2024-06-24 09:00:00 -0700"},
            {:start=>"2024-07-01 08:00:00 -0700", :end=>"2024-07-01 09:00:00 -0700"}
          ]
        )
      end
    end

    context 'when exclusion_times is provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-06-3',
          limit: 6,
          days_of_week: %w[mon],
          time_blocks: [
            { start_time: '8:00AM', end_time: '9:00AM' },
            { start_time: '10:00AM', end_time: '11:00AM' }
          ],
          exclusion_times: [
            {
              start: '2024-06-10T10:30:00-07:00',
              end: '2024-06-10T11:30:00-07:00'
            }
          ]
        )
      end

      it 'generates correct timeblocks' do
        time_blocks = human_readable(subject)
        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-06-03 08:00:00 -0700",
              :end=>"2024-06-03 09:00:00 -0700"
            },
            {
              :start=>"2024-06-03 10:00:00 -0700",
              :end=>"2024-06-03 11:00:00 -0700"
            },
            {
              :start=>"2024-06-10 08:00:00 -0700",
              :end=>"2024-06-10 09:00:00 -0700"
            },
            {
              :start=>"2024-06-17 08:00:00 -0700",
              :end=>"2024-06-17 09:00:00 -0700"
            },
            {
              :start=>"2024-06-17 10:00:00 -0700",
              :end=>"2024-06-17 11:00:00 -0700"
            },
            {
              :start=>"2024-06-24 08:00:00 -0700",
              :end=>"2024-06-24 09:00:00 -0700"
            }
          ]
        )
      end
    end

    context 'when days_of_month is provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-06-3',
          limit: 4,
          days_of_month: [5, 10],
          time_blocks: [
            { start_time: '8:00AM', end_time: '9:00AM' }
          ],
        )
      end

      it 'generates the correct days' do
        time_blocks = human_readable(subject)
        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-06-05 08:00:00 -0700",
              :end=>"2024-06-05 09:00:00 -0700"
            },
            {
              :start=>"2024-06-10 08:00:00 -0700",
              :end=>"2024-06-10 09:00:00 -0700"
            },
            {
              :start=>"2024-07-05 08:00:00 -0700",
              :end=>"2024-07-05 09:00:00 -0700"
            },
            {
              :start=>"2024-07-10 08:00:00 -0700",
              :end=>"2024-07-10 09:00:00 -0700"
            }
          ]
        )
      end
    end

    context 'when weeks_of_month and months is provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-04-1',
          limit: 5,
          weeks_of_month: [1, 2],
          months: [4, 5, 6],
          days_of_week: %w(mon),
          time_blocks: [
            { start_time: '8:00AM', end_time: '9:00AM' },
          ],
        )
      end

      it 'generates the right timeblocks' do
        time_blocks = human_readable(subject)

        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-04-01 08:00:00 -0700",
              :end=>"2024-04-01 09:00:00 -0700"
            },
           {
             :start=>"2024-04-08 08:00:00 -0700",
             :end=>"2024-04-08 09:00:00 -0700"
           },
           {
             :start=>"2024-05-06 08:00:00 -0700",
             :end=>"2024-05-06 09:00:00 -0700"
           },
           {
             :start=>"2024-06-03 08:00:00 -0700",
             :end=>"2024-06-03 09:00:00 -0700"
           },
           {
             :start=>"2025-04-07 08:00:00 -0700",
             :end=>"2025-04-07 09:00:00 -0700"
           },
          ]
        )
      end
    end

    context 'when nth_day_of_week_in_month is provided' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-06-01',
          limit: 5,
          nth_day_of_week_in_month: {
            mon: [1, 2],
            fri: [-1]
          },
          time_blocks: [
            { start_time: '8:00AM', end_time: '9:00AM' },
          ],
        )
      end

      it 'generates the right time blocks' do
        time_blocks = human_readable(subject)
        expect(time_blocks).to eq(
          [
            {:start=>"2024-06-03 08:00:00 -0700", :end=>"2024-06-03 09:00:00 -0700"},
            {:start=>"2024-06-10 08:00:00 -0700", :end=>"2024-06-10 09:00:00 -0700"},
            {:start=>"2024-06-28 08:00:00 -0700", :end=>"2024-06-28 09:00:00 -0700"},
            {:start=>"2024-07-01 08:00:00 -0700", :end=>"2024-07-01 09:00:00 -0700"},
            {:start=>"2024-07-08 08:00:00 -0700", :end=>"2024-07-08 09:00:00 -0700"}
          ]
        )
      end
    end

    context 'when alternating days of the week' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-12-30',
          days_of_week: {
            mon: { every: true }, # every Monday
            tue: { every_other_nth: 2 }, # every other Tuesday
            wed: { every_other_nth: 3 }, # every 3rd Wednesday
          },
          limit: 10,
          time_blocks: [
            { start_time: '9:00AM', end_time: '10:00AM' },
          ],
        )
      end

      it 'generates the correct timeblocks' do
        time_blocks = human_readable(subject)

        expect(time_blocks).to eq(
          [
            {
              :start=>"2024-12-30 09:00:00 -0800",
              :end=>"2024-12-30 10:00:00 -0800"
            },
            {
              :start=>"2024-12-31 09:00:00 -0800",
              :end=>"2024-12-31 10:00:00 -0800"
            },
            {
              :start=>"2025-01-01 09:00:00 -0800",
              :end=>"2025-01-01 10:00:00 -0800"
            },
            {
              :start=>"2025-01-06 09:00:00 -0800",
              :end=>"2025-01-06 10:00:00 -0800"
            },
            {
              :start=>"2025-01-13 09:00:00 -0800",
              :end=>"2025-01-13 10:00:00 -0800"
            },
            {
              :start=>"2025-01-14 09:00:00 -0800",
              :end=>"2025-01-14 10:00:00 -0800"
            },
            {
              :start=>"2025-01-20 09:00:00 -0800",
              :end=>"2025-01-20 10:00:00 -0800"
            },
            {
              :start=>"2025-01-22 09:00:00 -0800",
              :end=>"2025-01-22 10:00:00 -0800"
            },
            {
              :start=>"2025-01-27 09:00:00 -0800",
              :end=>"2025-01-27 10:00:00 -0800"
            },
            {
              :start=>"2025-01-28 09:00:00 -0800",
              :end=>"2025-01-28 10:00:00 -0800"
            }
          ]
        )
      end
    end

    context 'Friday the 13ths' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '1980-05-01',
          days_of_week: %w(fri),
          days_of_month: [13],
          limit: 10,
          time_blocks: [
            { start_time: '11:00PM', end_time: '12:00AM' },
          ],
        )
      end

      it 'generates the correct time slots' do
        time_blocks = human_readable(subject)
        expect(time_blocks).to eq(
          [
            {:start=>"1980-06-13 23:00:00 -0700",
            :end=>"1980-06-13 00:00:00 -0700"},
           {:start=>"1981-02-13 23:00:00 -0800",
            :end=>"1981-02-13 00:00:00 -0800"},
           {:start=>"1981-03-13 23:00:00 -0800",
            :end=>"1981-03-13 00:00:00 -0800"},
           {:start=>"1981-11-13 23:00:00 -0800",
            :end=>"1981-11-13 00:00:00 -0800"},
           {:start=>"1982-08-13 23:00:00 -0700",
            :end=>"1982-08-13 00:00:00 -0700"},
           {:start=>"1983-05-13 23:00:00 -0700",
            :end=>"1983-05-13 00:00:00 -0700"},
           {:start=>"1984-01-13 23:00:00 -0800",
            :end=>"1984-01-13 00:00:00 -0800"},
           {:start=>"1984-04-13 23:00:00 -0800",
            :end=>"1984-04-13 00:00:00 -0800"},
           {:start=>"1984-07-13 23:00:00 -0700",
            :end=>"1984-07-13 00:00:00 -0700"},
           {:start=>"1985-09-13 23:00:00 -0700",
            :end=>"1985-09-13 00:00:00 -0700"}
          ]
        )
      end
    end

    context 'Thanksgivings' do
      subject do
        Periodoxical.generate(
          time_zone: 'America/Los_Angeles',
          starting_from: '2024-05-01',
          months: [11],
          nth_day_of_week_in_month: {
            thu: [4],
          },
          limit: 10,
          time_blocks: [
            { start_time: '5:00PM', end_time: '6:00PM' },
          ],
        )
      end

      it 'generates the correct time slots' do
        time_blocks = human_readable(subject)

        expect(time_blocks).to eq(
          [
            {:start=>"2024-11-28 17:00:00 -0800", :end=>"2024-11-28 18:00:00 -0800"},
            {:start=>"2025-11-27 17:00:00 -0800", :end=>"2025-11-27 18:00:00 -0800"},
            {:start=>"2026-11-26 17:00:00 -0800", :end=>"2026-11-26 18:00:00 -0800"},
            {:start=>"2027-11-25 17:00:00 -0800", :end=>"2027-11-25 18:00:00 -0800"},
            {:start=>"2028-11-23 17:00:00 -0800", :end=>"2028-11-23 18:00:00 -0800"},
            {:start=>"2029-11-22 17:00:00 -0800", :end=>"2029-11-22 18:00:00 -0800"},
            {:start=>"2030-11-28 17:00:00 -0800", :end=>"2030-11-28 18:00:00 -0800"},
            {:start=>"2031-11-27 17:00:00 -0800", :end=>"2031-11-27 18:00:00 -0800"},
            {:start=>"2032-11-25 17:00:00 -0800", :end=>"2032-11-25 18:00:00 -0800"},
            {:start=>"2033-11-24 17:00:00 -0800", :end=>"2033-11-24 18:00:00 -0800"}]
        )
      end
    end
  end

  describe '#overlap?' do
    subject do
      Periodoxical::Core.new(
        starting_from: '2024-06-04', time_blocks: [], limit: 4
      ).send(:overlap?, time_block_1, time_block_2)
    end

    context 'when time_block_1 is before time_block_2 with no overlap' do
      let(:time_block_1) do
        {
          start: DateTime.parse("2024-06-03T9:00:00"),
          end: DateTime.parse("2024-06-03T10:00:00")
        }
      end

      let(:time_block_2) do
        {
          start: DateTime.parse("2024-06-03T10:00:00"),
          end: DateTime.parse("2024-06-03T12:00:00")
        }
      end

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when time_block_1 is after time_block_2 with no overlap' do
      let(:time_block_1) do
        {
          start: DateTime.parse("2024-06-03T10:00:00"),
          end: DateTime.parse("2024-06-03T12:00:00")
        }
      end

      let(:time_block_2) do
        {
          start: DateTime.parse("2024-06-03T9:00:00"),
          end: DateTime.parse("2024-06-03T10:00:00")
        }
      end

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when time_block_1 overlaps with time_block_2 case 1 ' do
      let(:time_block_1) do
        {
          start: DateTime.parse("2024-06-03T9:00:00"),
          end: DateTime.parse("2024-06-03T11:00:00")
        }
      end

      let(:time_block_2) do
        {
          start: DateTime.parse("2024-06-03T10:00:00"),
          end: DateTime.parse("2024-06-03T12:00:00")
        }
      end

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when time_block_1 overlaps with time_block_2 case 2 ' do
      let(:time_block_2) do
        {
          start: DateTime.parse("2024-06-03T9:00:00"),
          end: DateTime.parse("2024-06-03T11:00:00")
        }
      end

      let(:time_block_1) do
        {
          start: DateTime.parse("2024-06-03T10:00:00"),
          end: DateTime.parse("2024-06-03T12:00:00")
        }
      end

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when one is contained entirely within the other' do
      let(:time_block_1) do
        {
          start: DateTime.parse("2024-06-03T10:00:00"),
          end: DateTime.parse("2024-06-03T11:00:00")
        }
      end

      let(:time_block_2) do
        {
          start: DateTime.parse("2024-06-03T9:00:00"),
          end: DateTime.parse("2024-06-03T12:00:00")
        }
      end

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end
  end
end
