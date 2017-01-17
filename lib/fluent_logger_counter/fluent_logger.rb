module Fluent
  module Logger
    class FluentLogger
      def pending_bytesize
        if self.pending
          self.pending.bytesize
        else
          0
        end
      end
    end
  end
end
