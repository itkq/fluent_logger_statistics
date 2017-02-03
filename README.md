# FluentLoggerStatistics

## Usage
Middleware settings:
```ruby
Rails.configuration.middleware.use FluentLoggerStatistics::Middleware,
  '/endpoint',
  {
    resource_name1: fluent_logger1, # instance of Fluent::Logger::FluentLogger
    resource_name2: fluent_logger2,
    ...
  }
```

After rails boot, then
```sh
$ curl http://rails-host/endpoint/resource_name1 # no buffer used
{"buffer_bytesize":0,"buffer_limit":8388608,"buffer_usage_rate":0.0}

$ curl http://rails-host/endpoint/resource_name2 # buffered
{"buffer_bytesize":236,"buffer_limit":8388608,"buffer_usage_rate":2.8133392333984375e-05}
```
