# frozen_string_literal: true

require 'active_record/connection_adapters/column'

module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module SchemaStatements
        def tables(_name = nil)
          response = if ActiveRecord::VERSION::STRING >= '7.1.0'
                       with_raw_connection do |conn|
                         conn.query query_string: "SHOW TABLES FROM \"#{@config[:database]}\""
                       end
                     else
                       @connection.query query_string: "SHOW TABLES FROM \"#{@database}\""
                     end

          response.rows.map { |r| r.data[0].scalar_value }
        end

        def columns(table_name, _name = nil)
          response = if ActiveRecord::VERSION::STRING >= '7.1.0'
                       with_raw_connection do |conn|
                        conn.query query_string: "DESCRIBE \"#{@config[:database]}\".\"#{table_name}\""
                       end
                     else
                       @connection.query query_string: "DESCRIBE \"#{@config[:database]}\".\"#{table_name}\""
                     end

          response.rows.map do |r|
            AmazonTimestreamColumn.new r.data[0].scalar_value, nil, fetch_type_metadata(r.data[1].scalar_value)
          end
        end

        def table_exists?(table_name)
          tables.include?(table_name)
        end

        def primary_key(_table_name)
          nil
        end

        def data_sources
          tables
        end
      end
    end
  end
end
