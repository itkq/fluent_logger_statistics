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

      query = parse_query(env['QUERY_STRING'])
      if query["r"]
        rate = @fluent_logger.pending_bytesize/@fluent_logger.limit.to_f
        body = [{"buffer_usage_rate": rate}.to_json]
      else
        body = [{"buffer_size": @fluent_logger.pending_bytesize}.to_json]
      end

      [status, header, body]
    end
  end
end
