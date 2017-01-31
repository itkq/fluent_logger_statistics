require 'fluent-logger'

module FluentLoggerStatistics
  module FluentLoggerExt
    def pending_bytesize
      if @pending
        @pending.bytesize
      else
        0
      end
    end
  end
end

Fluent::Logger::FluentLogger.include(FluentLoggerStatistics::FluentLoggerExt)
