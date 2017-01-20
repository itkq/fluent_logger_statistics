require 'spec_helper'
require 'logger'
require 'fluent-logger'
require 'fluent_logger_counter/middleware'

module FluentLoggerCounter
  AppOriginal = App
end

describe 'middleware' do
  include Rack::Test::Methods

  let(:logger) { Logger.new(STDOUT) }
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

      attr_reader :logger, :options

      def call(env)
        [200, {'Content-Type' => 'application/json'}, ['{"buffer_size":0}']]
      end

      const_set(:ACCEPT_METHODS, %w[GET].freeze)
    end
  end

  let(:app) {
    FluentLoggerCounter::Middleware.new(nextapp, '/api/fluentcounter/test_logger', logger)
  }

  before do
    FluentLoggerCounter.send(:remove_const, :App)
    FluentLoggerCounter.const_set(:App, mockapp)
  end

  after do
    FluentLoggerCounter.send(:remove_const, :App)
    FluentLoggerCounter.const_set(:App, FluentLoggerCounter::AppOriginal)
  end

  it 'instantiates App with proper argument' do
    app

    expect(mockapp.instances.size).to be_eql 1
    expect(mockapp.instances.first.logger).to be_eql logger
  end

  it 'pass-through requests to nextapp' do
    get '/'
    expect(last_response.body).to be_eql 'OK'
    post '/'
    expect(last_response.body).to be_eql 'OK'
    get '/api/fluentcounter'
    expect(last_response.body).to be_eql 'OK'
    post '/api/fluentcounter/test_logger'
    expect(last_response.body).to be_eql 'OK'
  end

  it 'pass requests to FluentLoggerCounter::App on specific path' do
    get '/api/fluentcounter/test_logger'
    json = JSON.parse(last_response.body)
    expect(json["buffer_size"]).to be_eql 0
  end
end
