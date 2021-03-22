# frozen_string_literal: true

require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/amazon_timestream/database_statements'
require 'active_record/connection_adapters/amazon_timestream/quoting'
require 'active_record/connection_adapters/amazon_timestream/schema_statements'
require 'arel/visitors/amazon_timestream'
require 'aws-sdk-core'
require 'aws-sdk-timestreamquery'

module ActiveRecord
  class Base
    def self.amazon_timestream_connection(config)
      config = config.symbolize_keys

      raise ArgumentError, 'No database specified. Missing argument: database.' unless config.key?(:database)

      credentials = Aws::Credentials.new config[:username], config[:password] if config[:username] && config[:password]
      connection = Aws::TimestreamQuery::Client.new({ credentials: credentials }.compact)

      ConnectionAdapters::AmazonTimestreamAdapter.new connection, logger, config[:database]
    end
  end

  module ConnectionAdapters
    class AmazonTimestreamColumn < Column
      def sql_type
        @sql_type_metadata.class
      end
    end

    class AmazonTimestreamAdapter < AbstractAdapter
      ADAPTER_NAME = 'Amazon Timestream'

      include AmazonTimestream::SchemaStatements
      include AmazonTimestream::DatabaseStatements
      include AmazonTimestream::Quoting

      def initialize(connection, logger, database)
        super(connection, logger)
        @database = database
        @visitor = Arel::Visitors::AmazonTimestream.new self
      end

      def prepared_statements
        false
      end

      def supports_explain?
        false
      end

      def requires_reloading?
        false
      end

      def active?
        true
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
    end
  end
end
