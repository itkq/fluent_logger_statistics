module FluentLoggerCounter
  class App
    include Rack::Utils

    def initialize(fluent_logger)
      @fluent_logger = fluent_logger
    end

    ACCEPT_METHODS = ['GET'].freeze

    def call(env)
      unless ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        return [404, {'Content-Type' => 'text/plain'}, []]
      end

      status = 200
      header = {'Content-Type' => 'application/json'}

      bytesize = @fluent_logger.pending_bytesize
      limit = @fluent_logger.limit
      usage_rate = bytesize / limit.to_f

      body = [
        { buffer_bytesize: bytesize,
          buffer_limit: limit,
          buffer_usage_rate: usage_rate
        }.to_json
      ]

      [status, header, body]
    end
  end
end
