# frozen_string_literal: true

require 'active_record/result'

module ActiveRecord
  module ConnectionAdapters
    module AmazonTimestream
      module DatabaseStatements
        def select_rows(sql, name = nil, binds = [])
          exec_query(sql, name, binds).to_a.map(&:values)
        end

        if ActiveRecord::VERSION::STRING >= '7.1.0'
          def raw_execute(sql, name, async: false, allow_retry: false, materialize_transactions: true)
            log(sql, name, async: async) do
              with_raw_connection { |conn| conn.query query_string: sql }
            end
          end

          def internal_exec_query(sql, name = 'SQL', binds = [], prepare: false, async: false, allow_retry: false)
            log(sql, name, binds, async: async) do
              response_data = fetch_all_pages(sql)
              ActiveRecord::Result.new response_data[:column_names],
                                       response_data[:rows],
                                       column_types_from(response_data[:column_info])
            end
          end
        else
          def execute(sql, name = nil)
            log(sql, name) do
              @connection.query query_string: sql
            end
          end

          def exec_query(sql, name = 'SQL', binds = [], prepare: false)
            log(sql, name, binds) do
              response = @connection.query query_string: sql

              ActiveRecord::Result.new response.column_info.map(&:name),
                                       response.rows.map { |r| r.data.map(&:scalar_value) },
                                       column_types_from(response.column_info)
            end
          end
        end

        private

        def fetch_all_pages(sql)
          rows = []
          column_info = nil
          next_token = nil
          pages_fetched = 0

          max_pages = @config[:max_pages] || 30

          begin
            break if pages_fetched >= max_pages

            response = with_raw_connection do |conn|
              conn.query query_string: sql, next_token: next_token
            end

            rows.concat(response.rows.map { |r| r.data.map(&:scalar_value) })
            column_info ||= response.column_info
            next_token = response.next_token
            pages_fetched += 1
          end while next_token

          {
            column_names: column_info.map(&:name),
            rows: rows,
            column_info: column_info
          }
        end

        def column_types_from(column_info)
          column_info.each_with_object({}) { |c, h| h[c.name] = lookup_cast_type(c.type.scalar_type) }
        end
      end
    end
  end
end
