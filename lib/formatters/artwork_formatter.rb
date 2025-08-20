# frozen_string_literal: true

require 'json'
require_relative 'formatter'

module Formatters
  class ArtworkFormatter < Base
    def format(tiles, metadata: {})
      content_type = metadata[:content_type] || 'artworks'
      tiles_array = tiles || []
      
      result = {
        content_type.to_s => tiles_array.map { |tile| format_tile(tile) }
      }
      
      JSON.pretty_generate(result)
    end

    private

    def format_tile(tile_dto)
      result = {
        name: tile_dto.title,
        extensions: tile_dto.metadata,
        link: tile_dto.link
      }

      # Add image data if present
      if tile_dto.has_images? && tile_dto.primary_image
        result[:image] = tile_dto.primary_image.serializable_data
      end

      result
    end
  end
end