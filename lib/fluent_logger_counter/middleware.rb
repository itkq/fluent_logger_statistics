require "fluent_logger_counter/app"

module FluentLoggerCounter
  class Middleware
    def initialize(app, endpoint, loggers)
      @app = app
      @fluent_apps = loggers.map{|resource, logger|
        [ (Pathname.new(endpoint)+resource.to_s).to_s, App.new(logger) ]
      }.to_h
    end

    ACCEPT_METHODS = ['GET'].freeze

    def call(env)
      if @fluent_apps[env['PATH_INFO']] && ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        @fluent_apps[env['PATH_INFO']].call(env)
      else
        @app.call(env)
      end
    end
  end
end
