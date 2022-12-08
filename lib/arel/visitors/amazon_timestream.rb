# frozen_string_literal: true

require 'arel/visitors'

module Arel
  module Visitors
    class AmazonTimestream < Arel::Visitors::ToSql

      def preparable
        false
      end
      private

      def quote_table_name_without_database(name)
        return name if Arel::Nodes::SqlLiteral === name
        @connection.quote_table_name_without_database(name)
      end
      
      def visit_Arel_Attributes_Attribute(o, collector)
        if o.relation.table_alias
          collector << quote_table_name_without_database(o.relation.table_alias) << "." << quote_column_name(o.name)
        else
          collector << quote_table_name(o.relation.name) << "." << quote_column_name(o.name)
        end
      end
    end
  end
end

if ActiveRecord::VERSION::STRING < '5.0.0'
  Arel::Visitors::VISITORS['amazon_timestream'] = Arel::Visitors::AmazonTimestream
end
