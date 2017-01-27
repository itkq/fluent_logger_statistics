require "fluent_logger_statistics/app"

module FluentLoggerStatistics
  class Middleware
    def initialize(app, endpoint, loggers)
      @app = app
      @fluent_apps = loggers.map{|resource, logger|
        path = [ endpoint.chomp('/'), resource ].join('/')
        [ path, App.new(logger) ]
      }.to_h
    end

    ACCEPT_METHODS = ['GET'].freeze

    def call(env)
      path = env['PATH_INFO'].chomp('/')
      if @fluent_apps[path] && ACCEPT_METHODS.include?(env['REQUEST_METHOD'])
        @fluent_apps[path].call(env)
      else
        @app.call(env)
      end
    end
  end
end