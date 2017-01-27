require 'fluent-logger'

module FluentLoggerCounter
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

Fluent::Logger::FluentLogger.include(FluentLoggerCounter::FluentLoggerExt)
