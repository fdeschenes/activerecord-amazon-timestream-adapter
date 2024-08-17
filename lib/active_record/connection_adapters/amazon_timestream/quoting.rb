module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module Quoting
        if ActiveRecord::VERSION::STRING >= '7.2.0'
          extend ActiveSupport::Concern

          if ActiveRecord::VERSION::STRING >= '7.2.0'
            module ClassMethods
              def quote_column_name(column_name)
                column_name.to_s
              end

              def quote_table_name(table_name)
                database = @config[:database]
                "\"#{database}\".#{quote_table_name_without_database(table_name)}"
              end

              def quote_table_name_without_database(table_name)
                "\"#{quote_string(table_name)}\""
              end
            end
          end
        else
          def quote_table_name(table_name)
            database = ActiveRecord::VERSION::STRING >= '7.1.0' ? @config[:database] : @database
            "\"#{database}\".#{quote_table_name_without_database(table_name)}"
          end

          def quote_table_name_without_database(table_name)
            "\"#{quote_string(table_name)}\""
          end
        end
      end
    end
  end
end