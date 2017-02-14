module FluentLoggerStatistics
  class App
    include Rack::Utils

    def initialize(fluent_loggers)
      @fluent_loggers = fluent_loggers
    end

    ACCEPT_METHODS = ['GET'].freeze

    def call(env)
      unless ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        return [404, {'Content-Type' => 'text/plain'}, []]
      end

      status = 200
      header = {'Content-Type' => 'application/json'}

      stats = @fluent_loggers.map{|k,v|
        bytesize = v.pending_bytesize
        limit_bytesize = v.limit
        usage_rate = bytesize / limit_bytesize.to_f
        [k, {
          buffer_bytesize: bytesize,
          buffer_limit: limit_bytesize,
          buffer_usage_rate: usage_rate
        }]
      }.to_h

      body = [ stats.to_json ]

      [status, header, body]
    end
  end
end
