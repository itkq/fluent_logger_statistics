# copy from: https://github.com/fluent/fluent-logger-ruby/blob/0b1861c3ef72f4a60bb86078fdab7075d6ccaa00/spec/plugin/out_test.rb

#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'fluent/output'

module Fluent
  class TestOutput < Output
    Plugin.register_output('test', self)

    def initialize
      super

      @emit_streams = []
      @name = nil
    end

    attr_reader :emit_streams, :name

    def emits
      all = []
      @emit_streams.each {|tag,events|
        events.each {|time,record|
          all << [tag, time, record]
        }
      }
      all
    end

    def events
      all = []
      @emit_streams.each {|tag,events|
        all.concat events
      }
      all
    end

    def records
      all = []
      @emit_streams.each {|tag,events|
        events.each {|time,record|
          all << record
        }
      }
      all
    end

    def configure(conf)
      super

      if name = conf['name']
        @name = name
      end
    end

    def start
      super
    end

    def shutdown
      super
    end

    def emit(tag, es, chain)
      chain.next
      @emit_streams << [tag, es.to_a]
    end
  end
end
