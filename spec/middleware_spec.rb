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

      def initialize(logger)
        @logger = logger
        self.class.instances << self
      end

      attr_reader :logger

      def call(env)
        [200, {'Content-Type' => 'application/json'}, ['{"buffer_size":0}']]
      end

      const_set(:ACCEPT_METHODS, %w[GET].freeze)
    end
  end

  let(:app) {
    FluentLoggerStatistics::Middleware.new(
      nextapp,
      '/api/fluent_logger_statistics/',
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

    expect(mockapp.instances.size).to be_eql 2
    expect(mockapp.instances[0].logger).to be_eql logger1
    expect(mockapp.instances[1].logger).to be_eql logger2
  end

  it 'pass-through requests to nextapp' do
    get '/'
    expect(last_response.body).to be_eql 'OK'
    post '/'
    expect(last_response.body).to be_eql 'OK'
    get '/api/fluent_logger_statistics/'
    expect(last_response.body).to be_eql 'OK'
    post '/api/fluent_logger_statistics/'
    expect(last_response.body).to be_eql 'OK'
  end

  it 'pass requests to FluentLoggerStatistics::App on specific path' do
    get '/api/fluent_logger_statistics/stdout'
    json = JSON.parse(last_response.body)
    expect(json["buffer_size"]).to be_eql 0

    get '/api/fluent_logger_statistics/stderr'
    json = JSON.parse(last_response.body)
    expect(json["buffer_size"]).to be_eql 0
  end

  it 'pass requests to FluentLoggerStatistics::App with deleting end slash' do
    get '/api/fluent_logger_statistics/stdout/'
    json = JSON.parse(last_response.body)
    expect(json["buffer_size"]).to be_eql 0
  end
end
