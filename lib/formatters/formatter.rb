# frozen_string_literal: true

module Formatters
  class Base
    def format(tiles, metadata: {})
      result = {
        tiles: Array(tiles).map { |tile| format_tile(tile) }
      }

      result[:metadata] = metadata unless metadata.empty?

      result
    end

    private

    def format_tile(tile_dto)
      raise NotImplementedError, 'Subclasses must implement this method'
    end
  end
end
