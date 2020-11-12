# frozen_string_literal: true

require 'active_record/connection_adapters/amazon_timestream_adapter'

module ActiveRecord
  module ConnectionHandling
    def amazon_timestream_connection(config)
      config = config.symbolize_keys

      raise ArgumentError, 'No database specified. Missing argument: database.' unless config.key?(:database)

      ConnectionAdapters::AmazonTimestreamAdapter.new(logger, config)
    end
  end
end
