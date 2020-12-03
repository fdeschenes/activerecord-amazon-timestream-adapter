# frozen_string_literal: true

require 'arel/visitors'

module Arel
  module Visitors
    class AmazonTimestream < Arel::Visitors::ToSql
      def preparable
        false
      end
    end
  end
end

if ActiveRecord::VERSION::STRING < '5.0.0'
  Arel::Visitors::VISITORS['amazon_timestream'] = Arel::Visitors::AmazonTimestream
end
