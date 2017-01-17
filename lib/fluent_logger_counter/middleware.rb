require "fluent_logger_counter/app"

module FluentLoggerCounter
  class MiddleWare
    def initialize(app, logger, options={})
      @logger = logger
      @app = app
      @fluent_app = App.new(logger, **options)
    end

    ACCEPT_METHODS = ['GET'].freeze

    def call(env)
      if ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        @fluent_app.call(env)
      else
        @app.call(env)
      end
    end
  end
end
