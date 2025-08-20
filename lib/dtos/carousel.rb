# frozen_string_literal: true

require_relative 'item'

module DTOs
  class Carousel
    attr_reader :title, :items

    def initialize(title: '', items: [])
      @title = title
      @items = items.compact
    end

    def items_count
      items.length
    end

    def empty?
      items.empty?
    end
  end
end
