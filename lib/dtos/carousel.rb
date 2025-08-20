# frozen_string_literal: true

require_relative 'tile'

module DTOs
  class Carousel
    attr_reader :tiles, :metadata

    def initialize(tiles:, metadata: {})
      @tiles = Array(tiles).compact
      @metadata = metadata || {}
    end

    def tiles_count
      tiles.length
    end

    def tiles_with_images
      tiles.select(&:has_images?)
    end

    def tiles_with_metadata
      tiles.select(&:has_metadata?)
    end

    def empty?
      tiles.empty?
    end

    def content_types
      tiles.map(&:content_type).compact.uniq
    end
  end
end
