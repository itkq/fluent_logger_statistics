require 'spec_helper'
require 'support/dummy_serverengine'
require 'support/dummy_fluentd'
require 'fluent-logger'
require 'fluent_logger_statistics/middleware'

require 'logger'
require 'stringio'

describe 'app' do
  include Rack::Test::Methods

  let(:fluentd) { DummyFluentd.new }
  let(:logger) {
    @logger_io = StringIO.new
    logger = ::Logger.new(@logger_io)
    Fluent::Logger::FluentLogger.new('test', {
      :host => 'localhost',
      :port => fluentd.port,
      :logger => logger,
      :buffer_limit => 100,
    })
  }

  let(:app) { FluentLoggerStatistics::App.new({test_logger: logger}) }

  context "running fluentd" do
    before(:all) do
      @serverengine = DummyServerengine.new
      @serverengine.startup
    end

    before(:each) do
      fluentd.startup
    end

    after(:each) do
      fluentd.shutdown
    end

    after(:all) do
      @serverengine.shutdown
    end

    context "when a log send to fluentd" do
      it ('has no pending buffer') do
        logger.post('tag', {'a' => 'b'})
        get '/'
        json = JSON.parse(last_response.body)
        expect(json["test_logger"]["buffer_bytesize"]).to be_eql 0
        expect(json["test_logger"]["buffer_limit"]).to be_eql 100
        expect(json["test_logger"]["buffer_usage_rate"]).to be_eql 0.0
      end
    end
  end

  context "not running fluentd" do
    context "when a log send to fluentd" do
      it ('has pending buffer') do
        logger.post('tag', {'a' => 'b'})
        get '/'
        json = JSON.parse(last_response.body)
        expect(json["test_logger"]["buffer_bytesize"]).to be > 0
        expect(json["test_logger"]["buffer_limit"]).to be_eql 100
        expect(json["test_logger"]["buffer_usage_rate"]).to be > 0
      end
    end
  end
end
