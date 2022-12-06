# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module Quoting
        def quote_table_name(table_name)
          if table_exists?(table_name)
            "\"#{@database}\".\"#{quote_string(table_name)}\""
          else
            "\"#{quote_string(table_name)}\""
          end
        end
      end
    end
  end
end
