module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module Quoting
        def quote_table_name(table_name)
          "\"#{@database}\".\"#{quote_string(table_name)}\""
        end

        def quote_table_name_without_database(table_name)
          "\"#{quote_string(table_name)}\""
        end
      end
    end
  end
end