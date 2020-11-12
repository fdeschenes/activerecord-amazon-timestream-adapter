# frozen_string_literal: true

require 'active_record/connection_handling'
require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/amazon_timestream/database_statements'
require 'active_record/connection_adapters/amazon_timestream/quoting'
require 'active_record/connection_adapters/amazon_timestream/schema_statements'
require 'arel/visitors/amazon_timestream'
require 'aws-sdk-core'
require 'aws-sdk-timestreamquery'
require 'aws-sdk-timestreamwrite'

module ActiveRecord
  module ConnectionAdapters
    class AmazonTimestreamAdapter < AbstractAdapter
      ADAPTER_NAME = 'Amazon Timestream'

      include AmazonTimestream::SchemaStatements
      include AmazonTimestream::DatabaseStatements
      include AmazonTimestream::Quoting

      def initialize(logger, config)
        super(nil, logger)
        @config = config
        @visitor = Arel::Visitors::AmazonTimestream.new self
        connect!
      end

      def supports_explain?
        false
      end

      def requires_reloading?
        false
      end

      def active?
        @query.query({ query_string: 'SELECT 1' })
        true
      rescue StandardError
        false
      end

      protected

      def initialize_type_map(mapping)
        register_class_with_limit mapping, /boolean/i, Type::Boolean
        register_class_with_limit mapping, /date/i, Type::Date
        register_class_with_limit mapping, /double/i, Type::Float
        register_class_with_limit mapping, /int/i, Type::Integer
        register_class_with_limit mapping, /^time$/i, Type::Time
        register_class_with_limit mapping, /timestamp/i, Type::DateTime
        register_class_with_limit mapping, /varchar/i, Type::String

        mapping.alias_type(/unknown/i, 'varchar')
      end

      private

      def connect!
        if @config[:username] && @config[:password]
          credentials = Aws::Credentials.new(@config[:username], @config[:password])
        end

        @query = Aws::TimestreamQuery::Client.new credentials: credentials
        @write = Aws::TimestreamWrite::Client.new credentials: credentials
      end
    end
  end
end
