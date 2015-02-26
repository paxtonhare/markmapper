# encoding: UTF-8
module MarkMapper
  module Extensions
    module Date
      def to_marklogic(value)
        if value.nil? || (value.instance_of?(String) && '' === value)
          nil
        else
          date = value.instance_of?(::Date) || value.instance_of?(::Time) ? value : ::Date.parse(value.to_s)
          ::Time.utc(date.year, date.month, date.day)
        end
      rescue
        nil
      end

      def from_marklogic(value)
        value.to_date if value
      end

      def xs_type
        "date"
      end
    end
  end
end

class Date
  extend MarkMapper::Extensions::Date
end
