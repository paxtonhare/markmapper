require 'active_support/core_ext/time/zones'

# encoding: UTF-8
module MarkMapper
  module Extensions
    module Time
      def to_marklogic(value)
        if !value || '' == value
          nil
        else
          time_class = ::Time.zone || ::Time
          time = value.is_a?(::Time) ? value : time_class.parse(value.to_s, time_class.now)
          # time.iso8601
          # x = at(time.to_i, time.usec / 1000 * 1000).utc
          # x
        end
      end

      def from_marklogic(value)
        to_marklogic(value)
        # if value and zone = ::Time.zone
        #   value.in_time_zone(zone)
        # else
        #   value
        # end
      end

      def xs_type
        "dateTime"
      end
    end
  end
end

class Time
  extend MarkMapper::Extensions::Time
end
