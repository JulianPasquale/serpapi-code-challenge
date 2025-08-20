# frozen_string_literal: true

require_relative 'image'

module DTOs
  class Tile
    attr_reader :title, :metadata, :link, :images, :content_type

    def initialize(title:, link:, metadata: [], images: [], content_type: nil)
      @title = title
      @metadata = Array(metadata).compact.reject(&:empty?)
      @link = link
      @images = Array(images).compact
      @content_type = content_type
    end

    def primary_metadata
      metadata.first
    end

    def has_images?
      !images.empty? && images.any?(&:present?)
    end

    def primary_image
      images.find(&:present?)
    end

    def has_metadata?
      !metadata.empty?
    end
  end
end
