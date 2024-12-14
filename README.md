# ActiveRecord Amazon Timestream Adapter

This is the ActiveRecord adapter for working with [Amazon Timestream](https://aws.amazon.com/timestream/).

## Usage

```yaml
# database.yml
development:
  timestream:
    adapter: amazon_timestream
    database: events
    database_tasks: false
```

```ruby
# app/models/application_timestream_record.rb
class ApplicationTimestreamRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :timestream, reading: :timestream }
end
```

```ruby
# app/models/event.rb
class Event < ApplicationTimestreamRecord
end
```
