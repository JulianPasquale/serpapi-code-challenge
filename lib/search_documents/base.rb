# frozen_string_literal: true

require 'nokogiri'

module SearchDocuments
  class Base < Nokogiri::HTML::Document
    def carousel_elements_name
      raise NotImplementedError, 'Subclasses must implement this method'
    end

    def items_nodes
      raise NotImplementedError, 'Subclasses must implement this method'
    end
  end
end
