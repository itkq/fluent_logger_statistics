require 'fluent-logger'

module Fluent
  module Logger
    class FluentLogger
      def pending_bytesize
        if @pending
          @pending.bytesize
        else
          0
        end
      end
    end
  end
end
