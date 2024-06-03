# Periodoxical

_"Up, and down, and in the end, it's only round and round and round..._" - Pink Floyd, "Us and Them"

<div align="center">
  <img width="558" alt="pink_floyd_time" src="https://github.com/StevenJL/periodoxical/assets/2191808/8bab4a14-2df7-42d0-b6ae-f6b57a353500">
    <p><i>(Image Courtesy of "Pink Floyd: Time," directed by Ian Eames , ©1973)</i></p>
</div>

<br>

Generate periodic datetime blocks based on provided rules/conditions. Great for (but not limited to) calendar and scheduling applications. See Usage for detailed examples.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'periodoxical'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install periodoxical

## Usage

### Example 1
As a Ruby dev, I want to generate all the datetime blocks of **9:00AM - 10:30AM** for all days from **May 23, 2024** to **May 26, 2024** inclusive.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '10:30AM'
    },
  ],
  start_date: '2024-05-23',
  end_date: '2024-05-27',
)
#=> 
[
    {
     start_time: #<DateTime: 2024-05-23T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-23T10:30:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-24T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-24T10:30:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-25T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-25T10:30:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-26T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-26T10:30:00-0700>,
    }
]
```

### Example 2 - specify days of the week
As a Ruby dev, I want to generate all the datetime blocks of **9:00AM - 10:30AM** and **2:00PM - 2:30PM**, on **Mondays**, **Wednesdays**, and **Thursdays**, between the dates of **May 23, 2024** and **June 12, 2024**, inclusive. This can be represented visually as:

<div align="center">
  <img width="558" alt="calendar_image_1" src="https://github.com/StevenJL/periodoxical/assets/2191808/e92fc6ff-03fd-44ed-a955-d3a0dd0f5d0a">
    <p><i>(image courtesy of Cal.com)</i></p>
</div>

<br>

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  days_of_week: %w[mon wed thu],
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '10:30AM'
    },
    {
      start_time: '2:00PM',
      end_time: '2:30PM'
    }
  ],
  start_date: '2024-05-23',
  end_date: '2024-06-12',
)
# returns an array of hashes, each with :start and :end keys
#=> 
[
  {
    start: #<DateTime: 2024-05-23T09:00:00-0700">,
    end:   #<DateTime: 2024-05-23T22:30:00-0700">,
  },
  {
    start: #<DateTime: 2024-05-23T14:00:00-0700>,
    end:   #<DateTime: 2024-05-23T14:30:00-0700>,
  },
 {
    start: #<DateTime: 2024-05-27T09:00:00-0700>,
    end:   #<DateTime: 2024-05-27T22:30:00-0700>
 },
 ...
 {
    start: #<DateTime: 2024-06-12T14:00:00-0700>,
    end:   #<DateTime: 2024-06-12T14:30:00-0700>
 }
]
```

### Example 3 - using the `limit` key.

As a ruby dev, I want to generate the next **3** datetime blocks of **9:00AM - 10:30AM** and **2:00PM - 2:30PM** on **Sundays**, after **May 23, 2024** using the `limit` key.

```rb
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
  start_date: Date.parse('2024-05-23'), # Can also pass in `Date` object.
  limit: 3
)
# =>
[
  {
    start: #<DateTime: 2024-05-26T09:00:00-0700>,
    end:   #<DateTime: 2024-05-26T22:30:00-0700>,
  },
  {
    start: #<DateTime: 2024-05-26T14:00:00-0700>,
    end:   #<DateTime: 2024-05-26T14:30:00-0700>,
  },
  {
    start: #<DateTime: 2024-06-02T09:00:00-0700>,
    end:   #<DateTime: 2024-06-02T22:30:00-0700>,
  },
]
```

### Example 4 - when time blocks vary between days

As a ruby dev, I want to generate all the timeblocks between **May 23, 2024** and **June 12, 2024** where the time should be **8AM-9AM** on **Mondays**, but **10:45AM-12:00PM** and **2:00PM-4:00PM** on **Wednesdays**, and **2:30PM-4:15PM** on **Thursdays**.

<div align="center">
  <img width="628" alt="calendar_image_2" src="https://github.com/StevenJL/periodoxical/assets/2191808/26d14824-08ff-481a-97e2-9b6b11beea29">
  <p><i>(image courtesy of Cal.com)</i></p>
</div>

<br>

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: Date.parse('2024-05-23'), # can also pass in Date objects
  end_date: Date.parse('2024-06-12'), # can also pass in Date objects,
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
```

### Example 5 - when specifying time blocks using day-of-month and/or week-of-month and/or month.

As a Ruby dev, I want to generate the next 3 timeblocks for **8AM - 9AM** for the **5th** and **10th** day of every month starting from **June**

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-06-1',
  limit: 3,
  days_of_month: [5, 10],
  time_blocks: [
    { start_time: '8:00AM', end_time: '9:00AM' },
  ],
)
#=>
[
    {
      start: #<DateTime: 2024-06-05T08:00:00-0700>,
      end: #<DateTime: 2024-06-05T09:00:00-0700>,
    },
    {
      start: #<DateTime: 2024-06-10T08:00:00-0700>,
      end: #<DateTime: 2024-06-10T09:00:00-0700>,
    },
    {
      start: #<DateTime: 2024-07-05T08:00:00-0700>,
      end: #<DateTime: 2024-07-05T09:00:00-0700>,
    },
]
```

As a Ruby dev, I want to generate **4** timeblocks for **8AM - 9AM** on **Mondays** but only in the **first two weeks** in the months of **April, May, and June**

```
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-04-1',
  limit: 4,
  weeks_of_month: [1 2],
  months: [4, 5, 6],
  days_of_week: %w(mon),
  time_blocks: [
    { start_time: '8:00AM', end_time: '9:00AM' },
  ],
)
#=> 
[
    {
     start_time: #<DateTime: 2024-04-01T08:00:00-0700>,
     end_time: #<DateTime: 2024-04-01T09:00:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-04-08T08:00:00-0700>,
     end_time: #<DateTime: 2024-04-08T09:00:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-06T08:00:00-0700>,
     end_time: #<DateTime: 2024-05-06T09:00:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-06-03T08:00:00-0700>,
     end_time: #<DateTime: 2024-06-03T09:00:00-0700>,
    },
]
```

### Example 6 - Specify nth day-of-week in month (ie. first Monday of the Month, second Tuesday of the Month, last Friday of Month)
As a Ruby dev, I want to generate timeblocks for **8AM - 9AM** on the **first and second Mondays**  and **last Fridays** of every month starting in June 2024.  I can do this with the `nth_day_of_week_in_month` param.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-06-01',
  limit: 5,
  nth_day_of_week_in_month: {
    mon: [1, 2], # valid values: -1,1,2,3,4,5
    fri: [-1], # Use -1 to specify "last" of the month.
  },
  time_blocks: [
    { start_time: '8:00AM', end_time: '9:00AM' },
  ],
)
# =>
[
  {
    start: #<DateTime: 2024-06-03T08:00:00-0700>, # First Monday of June 2024
    end: #<DateTime: 2024-06-03T09:00:00-0700>,
  },
  {
    start: #<DateTime: 2024-06-10T08:00:00-0700>, # second Monday of June 2024
    end: #<DateTime: 2024-06-10T09:00:00-0700>,
  },
  {
    start: #<DateTime: 2024-06-28 08:00:00 -0700>, # last Friday of June 2024
    end: #<DateTime: 2024-06-28 09:00:00 -0700>,
  },
  {
    start: #<DateTime: 2024-07-01 08:00:00 -0700>, # First Monday of July 2024
    end: #<DateTime: 2024-07-01 09:00:00 -0700>,
  },
  {
    start: #<DateTime: 2024-07-08 08:00:00 -0700>, # Second Monday of July 2024
    end: #<DateTime: 2024-07-08 09:00:00 -0700>,
  },
]
```

### Example 7 - Exclude time blocks using the `exclusion_dates` parameter
As a Ruby dev, I want to generate timeblocks for **8AM - 9AM** on **Mondays**, except for the **Monday of June 10, 2024**.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-06-3',
  limit: 4,
  exclusion_dates: %w(2024-06-10),
  day_of_week_time_blocks: {
    mon: [
      { start_time: '8:00AM', end_time: '9:00AM' },
    ],
  }
)
# Returns all Monday 8AM - 9AM blocks except for the Monday on June 10, 2024
# => 
[
    {
      start: #<DateTime: 2024-06-03T08:00:00-0700>,
      end: #<DateTime: 2024-06-03T09:00:00-0700>,
    }
    {
      start: #<DateTime: 2024-06-17T08:00:00-0700>,
      end: #<DateTime: 2024-06-17T09:00:00-0700>,
    }
    {
      start: #<DateTime: 2024-06-24T08:00:00-0700>,
      end: #<DateTime: 2024-06-24T09:00:00-0700>,
    }
    {
      start: #<DateTime: 2024-07-01T08:00:00-0700>,
      end: #<DateTime: 2024-07-01T09:00:00-0700>,
    }
]
```

### Example 8 - Every-other-nth day-of-week rules (ie. every other Tuesday, every 3rd Wednesday, every 10th Friday)

As a Ruby dev, I want to generate timeblocks for **9AM- 10AM** on **every Monday**, but **every other Tuesday**, and **every other 3rd Wednesday**. I can do this using the `days_of_week` parameter, but also using the `every` and `every_other_nth` keys to specify the every-other-nth-rules.

This can be visualized as:

<div align="center">
  <img width="600" alt="alt_google_cal_image" src="https://github.com/StevenJL/periodoxical/assets/2191808/d663da17-a94a-4715-886a-8223b129dd60">
  <p><i>(image courtesy of calendar.google.com)</i></p>
</div>

<br>

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-12-30',
  days_of_week: {
    mon: { every: true }, # every Monday (no skipping)
    tue: { every_other_nth: 2 }, # every other Tuesday starting at first Tuesday from start date
    wed: { every_other_nth: 3 }, # every 3rd Wednesday starting at first Wednesday from start date
  },
  limit: 10,
  time_blocks: [
    { start_time: '9:00AM', end_time: '10:00AM' },
  ],
)
#=> 
[
    {
       start: #<DateTime: 2024-12-30T09:00:00-0800>,
       end: #<DateTime: 2024-12-30T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2024-12-31T09:00:00-0800>,
       end: #<DateTime: 2024-12-31T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-01T09:00:00-0800>,
       end: #<DateTime: 2025-01-01T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-06T09:00:00-0800>,
       end: #<DateTime: 2025-01-06T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-13T09:00:00-0800>,
       end: #<DateTime: 2025-01-13T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-14T09:00:00-0800>,
       end: #<DateTime: 2025-01-14T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-20T09:00:00-0800>,
       end: #<DateTime: 2025-01-20T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-22T09:00:00-0800>,
       end: #<DateTime: 2025-01-22T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-27T09:00:00-0800>,
       end: #<DateTime: 2025-01-27T10:00:00-0800>,
    },
    {
       start: #<DateTime: 2025-01-28T09:00:00-0800>,
       end: #<DateTime: 2025-01-28T10:00:00-0800>,
    }
]
```

### Having Some Fun

Generate all the Friday the 13ths ever since May 1980 (when the first Friday the 13th film was released).

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '1980-05-01',
  days_of_week: %w(fri),
  days_of_month: [13],
  limit: 100,
  time_blocks: [
    { start_time: '11:00PM', end_time: '12:00AM' },
  ],
)
# =>
[
    {
      start: #<DateTime: 1980-06-13T23:00:00-0700>,
      end: #<DateTime: 1980-06-13T00:00:00-0700>,
    },
    {
      start: #<DateTime: 1981-02-13T23:00:00-0800>,
      end: #<DateTime: 1981-02-13T00:00:00-0800>,
    },
    {
      start: #<DateTime: 1981-03-13T23:00:00-0800>,
      end: #<DateTime: 1981-03-13T00:00:00-0800>,
    },
    {
      start: #<DateTime: 1981-11-13T23:00:00-0800>,
      end: #<DateTime: 1981-11-13T00:00:00-0800>,
    }
    ...
]
```

Generate the next 10 Thanksgivings from now on (Thanksgivings is defined as the 4th Thursday in November).

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-05-01',
  months: [11],
  nth_day_of_week_in_month: {
    thu: [4],
  },
  limit: 10,
  time_blocks: [
    { start_time: '5:00PM', end_time: '6:00PM' },
  ],
)
#=>
[
    {
      start: #<DateTime: 2024-11-28T17:00:00-0800>,
      end: #<DateTime: 2024-11-28T18:00:00-0800>,
    },
    {
      start: #<DateTime: 2025-11-27T17:00:00-0800>,
      end: #<DateTime: 2025-11-27T18:00:00-0800>,
    },
    {
      start: #<DateTime: 2026-11-26T17:00:00-0800>,
      end: #<DateTime: 2026-11-26T18:00:00-0800>,
    },
    {
      start: #<DateTime: 2027-11-25T17:00:00-0800>,
      end: #<DateTime: 2027-11-25T18:00:00-0800>,
    },
    {
      start: #<DateTime: 2028-11-23T17:00:00-0800>,
      end: #<DateTime: 2028-11-23T18:00:00-0800>,
    }
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/periodoxical. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Periodoxical project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/periodoxical/blob/master/CODE_OF_CONDUCT.md).
