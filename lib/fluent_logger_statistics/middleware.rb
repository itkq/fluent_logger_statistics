require "fluent_logger_statistics/app"

module FluentLoggerStatistics
  class Middleware
    def initialize(app, path, loggers)
      @app = app
      @path = path
      @fluent_app = App.new(loggers)
    end

    ACCEPT_METHODS = ['GET'].freeze

    def call(env)
      if env['PATH_INFO'] == @path && ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        @fluent_app.call(env)
      else
        @app.call(env)
      end
    end
  end
end
