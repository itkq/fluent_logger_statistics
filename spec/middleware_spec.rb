require 'spec_helper'
require 'logger'
require 'fluent-logger'
require 'fluent_logger_statistics/middleware'

module FluentLoggerStatistics
  AppOriginal = App
end

describe 'middleware' do
  include Rack::Test::Methods

  let(:logger1) { Logger.new(STDOUT) }
  let(:logger2) { Logger.new(STDERR) }
  let(:nextapp) { -> (env) { [200, {'Content-Type' => 'text/plain'}, ['OK']] } }
  let(:mockapp) do
    Class.new do
      def self.instances
        @instances ||= []
      end

      def initialize(loggers)
        @loggers = loggers
        self.class.instances << self
      end

      attr_reader :loggers

      def call(env)
        [
          200,
          {'Content-Type' => 'application/json'},
          ['{"stdout":{"buffer_bytesize":0,"buffer_limit":8388608,"buffer_usage_rate":0.0},"stderr":{"buffer_bytesize":0,"buffer_limit":8388608,"buffer_usage_rate":0.0}}']]
      end

      const_set(:ACCEPT_METHODS, %w[GET].freeze)
    end
  end

  let(:app) {
    FluentLoggerStatistics::Middleware.new(
      nextapp,
      '/fluent_logger_stats/',
      {"stdout" => logger1, "stderr" => logger2}
    )
  }

  before do
    FluentLoggerStatistics.send(:remove_const, :App)
    FluentLoggerStatistics.const_set(:App, mockapp)
  end

  after do
    FluentLoggerStatistics.send(:remove_const, :App)
    FluentLoggerStatistics.const_set(:App, FluentLoggerStatistics::AppOriginal)
  end

  it 'instantiates App with proper argument' do
    app

    expect(mockapp.instances.size).to be_eql 1
    expect(mockapp.instances.first.loggers["stdout"]).to be_eql logger1
    expect(mockapp.instances.first.loggers["stderr"]).to be_eql logger2
  end

  it 'pass-through requests to nextapp' do
    get '/'
    expect(last_response.body).to be_eql 'OK'
    post '/'
    expect(last_response.body).to be_eql 'OK'
    post '/fluent_logger_stats/'
    expect(last_response.body).to be_eql 'OK'
  end

  it 'pass requests to FluentLoggerStatistics::App on specific path' do
    get '/fluent_logger_stats/'
    json = JSON.parse(last_response.body)
    expect(json["stdout"]["buffer_bytesize"]).to be_eql 0
    expect(json["stderr"]["buffer_bytesize"]).to be_eql 0
  end

end
