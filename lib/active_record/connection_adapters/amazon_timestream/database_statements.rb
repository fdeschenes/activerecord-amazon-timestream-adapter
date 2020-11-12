# frozen_string_literal: true

require 'active_record/result'

module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module DatabaseStatements
        def execute(sql, name = nil)
          log(sql, name) do
            @query.query({ query_string: sql })
          end
        end

        def select_rows(sql, name = nil, binds = [])
          exec_query(sql, name, binds).to_a.map(&:values)
        end

        def exec_query(sql, name = 'SQL', binds = [])
          log(sql, name, binds) do
            response = @query.query query_string: sql

            ActiveRecord::Result.new response.column_info.map(&:name),
                                     response.rows.map { |r| r.data.map(&:scalar_value) },
                                     column_types_from(response.column_info)
          end
        end

        private

        def column_types_from(column_info)
          column_info.each_with_object({}) { |c, h| h[c.name] = lookup_cast_type(c.type.scalar_type) }
        end
      end
    end
  end
end
