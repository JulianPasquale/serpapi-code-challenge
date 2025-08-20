# frozen_string_literal: true

require 'json'
require_relative 'formatter'

module Formatters
  class JsonFormatter < Base
    def format(tiles, metadata: {})
      result = super(tiles, metadata: metadata)
      JSON.pretty_generate(result)
    end

    private

    def format_tile(tile_dto)
      result = {
        title: tile_dto.title,
        metadata: tile_dto.metadata,
        link: tile_dto.link
      }

      # Add content type if present
      result[:content_type] = tile_dto.content_type if tile_dto.content_type

      # Add image data if present
      result[:image] = tile_dto.primary_image.serializable_data if tile_dto.has_images? && tile_dto.primary_image

      result
    end
  end
end
