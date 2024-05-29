require "pry"
require "date"

RSpec.describe Periodoxical do
  it "has a version number" do
    expect(Periodoxical::VERSION).not_to be nil
  end

  describe '.generate' do
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
          start_date: Date.parse('2024-05-23'),
          end_date: Date.parse('2024-06-12')
        )
      end

      it "generates all the times 9:00AM to 10:30PM, 2:00PM to 2:30PM on Mondays, Wednesdays, and Thursdays, between May 23, 2024 and June 12, 2024" do
        time_blocks = subject
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
        expect(time_blocks_str).to eq(
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
          start_date: Date.parse('2024-05-23'),
          limit: 5
        )
      end

      it "generates 5 all the times 9:00AM to 10:30PM, 2:00PM to 2:30PM on Sundays" do
        time_blocks = subject
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
        expect(time_blocks_str).to eq(
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

    context 'when timeblock varies between days' do
       
    end
  end
end
