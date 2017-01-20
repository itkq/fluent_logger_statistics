module FluentLoggerCounter
  class App
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
      body = [{"buffer_size": @fluent_logger.pending_bytesize}.to_json]

      [status, header, body]
    end
  end
end
