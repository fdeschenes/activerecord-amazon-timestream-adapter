# frozen_string_literal: true

require 'active_record/connection_adapters/column'

module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module SchemaStatements
        def tables(_name = nil)
          response = @connection.query({ query_string: "SHOW TABLES FROM \"#{@database}\"" })
          response.rows.map { |r| r.data[0].scalar_value }
        end

        def columns(table_name, _name = nil)
          response = @connection.query({ query_string: "DESCRIBE \"#{@database}\".\"#{table_name}\"" })
          response.rows.map { |r| Column.new(r.data[0].scalar_value, nil, lookup_cast_type(r.data[1].scalar_value)) }
        end

        def table_exists?(_table_name)
          tables.include?(table_name)
        end

        def primary_key(_table_name)
          nil
        end
      end
    end
  end
end
