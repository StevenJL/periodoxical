require "pry"
require "date"

RSpec.describe Periodoxical do
  it "has a version number" do
    expect(Periodoxical::VERSION).not_to be nil
  end

  describe '.generate' do
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
        end_date: Date.parse('2024-06-24')
      )
    end

    it "generates all the times 9:00AM to 10:30PM, 2:00PM to 2:30PM on Mondays, Wednesdays, and Thursdays, between May 23, 2024 and June 24, 2024" do
      subject
    end
  end
end
