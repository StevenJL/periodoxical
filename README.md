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

### Basic Example
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
  starting_from: '2024-05-23',
  ending_at: '2024-05-26',
)
#=> 
[
    {
     start: #<DateTime: 2024-05-23T09:00:00-0700>,
     end: #<DateTime: 2024-05-23T10:30:00-0700>,
    },
    {
     start: #<DateTime: 2024-05-24T09:00:00-0700>,
     end: #<DateTime: 2024-05-24T10:30:00-0700>,
    },
    {
     start: #<DateTime: 2024-05-25T09:00:00-0700>,
     end: #<DateTime: 2024-05-25T10:30:00-0700>,
    },
    {
     start: #<DateTime: 2024-05-26T09:00:00-0700>,
     end: #<DateTime: 2024-05-26T10:30:00-0700>,
    }
]
```

The `starting_from` and `ending_at` params can also accept datetimes in ISO 8601 format. This example generate all the datetime blocks of **9:00AM - 10:30AM** but starting from **May 23, 2024 at 9:30AM**.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '10:30AM'
    },
  ],
  starting_from: '2024-05-23T09:30:00-07:00', # can be string in iso8601 format
  ending_at: DateTime.parse('2024-05-26T17:00:00-07:00'), # or an instance of DateTime
)
#=> [
    # 2024-05-23 was skipped because the 9AM time block was before
    # the `starting_from` of '2024-05-23T09:30:00-07:00'
    {
     start_time: #<DateTime: 2024-05-24T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-24T10:30:00-0700>,
    },
    ...
]
```

### Specify days of the week
As a Ruby dev, I want to generate all the datetime blocks of **9:00AM - 10:30AM** and **2:00PM - 2:30PM**, on **Mondays**, **Wednesdays**, and **Thursdays**, between the dates of **May 23, 2024** and **June 12, 2024**, inclusive. I can do this using the `days_of_week` parameter. This can be represented visually as:

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
  starting_from: '2024-05-23',
  ending_at: '2024-06-12',
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

### Example using the `limit` parameter.

As a ruby dev, I want to generate the next **3** datetime blocks of **9:00AM - 10:30AM** and **2:00PM - 2:30PM** on **Sundays**, after **May 23, 2024**. I can do this using the `limit` parameter, instead of `ending_at`.

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
  starting_from: Date.parse('2024-05-23'), # Can also pass in `Date` object.
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

### Time blocks that vary between days-of-the-week

As a ruby dev, I want to generate all the timeblocks between **May 23, 2024** and **June 12, 2024** where the time should be **8AM-9AM** on **Mondays**, but **10:45AM-12:00PM** and **2:00PM-4:00PM** on **Wednesdays**, and **2:30PM-4:15PM** on **Thursdays**.  I can do this using the `day_of_week_time_blocks` parameter.

<div align="center">
  <img width="628" alt="calendar_image_2" src="https://github.com/StevenJL/periodoxical/assets/2191808/26d14824-08ff-481a-97e2-9b6b11beea29">
  <p><i>(image courtesy of Cal.com)</i></p>
</div>

<br>

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  starting_from: Date.parse('2024-05-23'), # can also pass in Date objects
  ending_at: Date.parse('2024-06-12'), # can also pass in Date objects,
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

### Specifying time blocks using rules for month(s) and/or day-of-month.

As a Ruby dev, I want to generate the next 3 timeblocks for **8AM - 9AM** for the **5th** and **10th** day of every month starting from **June**.  I can do this using the `days_of_month` parameter.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  starting_from: '2024-06-01',
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

### Specify nth day-of-week in month (ie. first Monday of the Month, second Tuesday of the Month, last Friday of Month)

As a Ruby dev, I want to generate timeblocks for **8AM - 9AM** on the **first and second Mondays**  and **last Fridays** of every month starting in June 2024.  I can do this with the `nth_day_of_week_in_month` param.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  starting_from: '2024-06-01',
  limit: 5,
  nth_day_of_week_in_month: {
    mon: [1, 2], # valid values: -1,1,2,3,4,5
    fri: [-1], # Use -1 to specify the last Friday of the month.
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

### Exclude time blocks using the `exclusion_dates` and `exclusion_times` parameters
As a Ruby dev, I want to generate timeblocks for **8AM - 9AM** on **Mondays**, except for the **Monday of June 10, 2024**.  I can do this using the `exlcusion_dates` parameter.

```rb
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

As a Ruby dev, I want to generate timeblocks for **8AM - 9AM**, and **10AM - 11AM** on **Mondays**, except for those that conflict (meaning overlap) with the time block of **10:30AM - 11:30AM** on the **Monday of June 10, 2024**.  I can skip the conflicting time blocks by using the `exclusion_times` parameter.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  starting_from: '2024-06-03',
  limit: 4,
  days_of_week: %(mon),
  time_blocks: [
      { start_time: '8:00AM', end_time: '9:00AM' },
      { start_time: '10:00AM', end_time: '11:00AM' },
  ],
  exclusion_times: [
    {
        start: '2024-06-10T10:30:00-07:00',
        end: '2024-06-10T11:30:00-07:00',
    }
  ],
)
# =>
[
    {
      start: #<DateTime 2024-06-03T08:00:00-0700>,
      end: #<DateTime 2024-06-03T09:00:00-0700>,
    },
    {
      start: #<DateTime 2024-06-03T10:00:00-0700>,
      end: #<DateTime 2024-06-03T11:00:00-0700>,
    },
    {
      start: #<DateTime 2024-06-10T08:00:00-0700>,
      end: #<DateTime 2024-06-10T09:00:00-0700>,
    },
    # The June 10 10AM - 11AM was skipped because it overlapped with the June 10 10:30AM - 11:30AM exclusion time.
    {
      start: #<DateTime 2024-06-17T08:00:00-0700>,
      end: #<DateTime 2024-06-17T09:00:00-0700>,
    },
    {
      start: #<DateTime 2024-06-17T10:00:00-0700>,
      end: #<DateTime 2024-06-17T11:00:00-0700>,
    },
    {
      start: #<DateTime 2024-06-24T08:00:00-0700>,
      end: #<DateTime 2024-06-24T09:00:00-0700>,
    },
]
```

### Every-other-nth day-of-week rules (ie. every other Tuesday, every 3rd Wednesday, every 10th Friday)

As a Ruby dev, I want to generate timeblocks for **9AM- 10AM** on **every Monday**, but **every other Tuesday**, and **every other 3rd Wednesday**. I can do this using the `days_of_week` parameter with the `every` and `every_other_nth` keys to specify the every-other-nth-rules.

This can be visualized as:

<div align="center">
  <img width="600" alt="alt_google_cal_image" src="https://github.com/StevenJL/periodoxical/assets/2191808/d663da17-a94a-4715-886a-8223b129dd60">
  <p><i>(image courtesy of calendar.google.com)</i></p>
</div>

<br>

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  starting_from: '2024-12-30',
  days_of_week: {
    mon: { every: true }, # every Monday (no skipping)
    tue: { every_other_nth: 2 }, # every other Tuesday starting at first Tuesday from `starting_from` date
    wed: { every_other_nth: 3 }, # every 3rd Wednesday starting at first Wednesday from `starting_from` date
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

### Use the `duration` key, to automatically partition the provided `time_blocks` into smaller chunks to the given duration.

As a Ruby dev, I want to generate **30 minute** time blocks between **9:00AM - 1:00PM, and 2:00PM - 5:00PM**.  Because it is too tedious to generate all 14 of these time blocks, I prefer to pass in the `duration` key and have `periodoxical` generate them for me.

N.B. If you provide a duration that conflicts with your time blocks, `periodoxical` will not return any time blocks.  For example, if you specify **9:00AM - 10:00AM** but set your **duration** as  90 minutes, no time blocks are generated since we can't fit 90 minutes into an hour!


```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '1:00PM'
    },
    {
      start_time: '2:00PM',
      end_time: '5:00PM'
    },
  ],
  duration: 30, #(minutes)
  starting_from: '2024-05-23',
  ending_at: '2024-05-26',
)
# => [
    {
      start: #<DateTime: 2024-05-23T09:00:00--0700>
      end: #<DateTime: 2024-05-23T09:30:00--0700>
    },
    {
      start: #<DateTime: 2024-05-23T09:30:00--0700>
      end: #<DateTime: 2024-05-23T10:00:00--0700>
    },
    {
      start: #<DateTime: 2024-05-23T10:00:00--0700>
      end: #<DateTime: 2024-05-23T10:30:00--0700>
    },
    {
      start: #<DateTime: 2024-05-23T10:30:00--0700>
      end: #<DateTime: 2024-05-23T11:00:00--0700>
    }
]
```

### Having Some Fun

Generate all the Friday the 13ths ever since May 1980 (when the first Friday the 13th film was released).

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  starting_from: '1980-05-01',
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
    },
    ...
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
