# FluentLoggerCounter

## Usage
Middleware settings
```ruby
Rails.configuration.middleware.use FluentLoggerCounter::Middleware,
  '/endpoint',
  {
    resource_name1: fluent_logger1, # instance of Fluent::Logger::FluentLogger
    resource_name2: fluent_logger2,
    ...
  }
```

Then
```sh
$ curl http://rails-host/endpoint/resource_name1
{"buffer_size":0}
```
