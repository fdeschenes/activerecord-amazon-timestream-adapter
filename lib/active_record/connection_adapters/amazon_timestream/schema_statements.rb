# frozen_string_literal: true

require 'active_record/connection_adapters/column'

module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module SchemaStatements
        def tables(_name = nil)
          response = @write.list_tables database_name: @config[:database]

          response.tables.map(&:table_name)
        end

        def columns(table_name, _name = nil)
          response = @query.query query_string: "SELECT * FROM #{quote_table_name(table_name)} LIMIT 1"
          response.column_info.map do |column|
            Column.new(column.name, nil, lookup_cast_type(column.type.scalar_type))
          end
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
