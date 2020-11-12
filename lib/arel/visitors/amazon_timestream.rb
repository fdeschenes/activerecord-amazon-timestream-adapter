# frozen_string_literal: true

require 'arel/visitors'

module Arel
  module Visitors
    class AmazonTimestream < Arel::Visitors::ToSql
    end
  end
end

Arel::Visitors::VISITORS['amazon_timestream'] = Arel::Visitors::AmazonTimestream
