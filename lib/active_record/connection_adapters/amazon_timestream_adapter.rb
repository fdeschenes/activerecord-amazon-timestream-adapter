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

      if ActiveRecord::VERSION::STRING >= '7.1.0'
        ConnectionAdapters::AmazonTimestreamAdapter.new config
      else
        credentials = if config[:username] && config[:password]
          Aws::Credentials.new(*config.values_at(:username, :password, :session_token))
        end
        connection = Aws::TimestreamQuery::Client.new({ credentials: credentials }.compact)

        ConnectionAdapters::AmazonTimestreamAdapter.new connection, logger, config[:database]
      end
    end
  end

  module ConnectionAdapters
    if ActiveRecord::VERSION::STRING >= '7.2.0'
      register 'amazon_timestream', 'ActiveRecord::ConnectionAdapters::AmazonTimestreamAdapter',
               'active_record/connection_adapters/amazon_timestream/adapter'
    end

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

      if ActiveRecord::VERSION::STRING < '7.1.0'
        def initialize(connection, logger = nil, database = nil)
          super(connection, logger, database)
          @database = database
        end
      end

      def configure_connection
        credentials = if @config[:username] && @config[:password]
          Aws::Credentials.new(*@config.values_at(:username, :password, :session_token))
        end
        @raw_connection = Aws::TimestreamQuery::Client.new({ credentials: credentials }.compact)
      end

      def reconnect
      end

      def arel_visitor
        Arel::Visitors::AmazonTimestream.new self
      end

      def prepared_statements
        false
      end

      def supports_common_table_expressions?
        true
      end

      def active?
        return true unless ActiveRecord::VERSION::STRING >= '7.1.0'

        @lock.synchronize do
          !@raw_connection.nil?
        end
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
