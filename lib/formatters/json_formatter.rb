# frozen_string_literal: true

require 'json'
require_relative 'base'

module Formatters
  class JsonFormatter < Base
    def parse(carousel)
      JSON.pretty_generate(
        {
          carousel.title => carousel.items.map(&method(:format_item))
        }
      )
    end

    private

    def format_item(item_dto)
      {
        name: item_dto.name,
        extensions: item_dto.extensions,
        link: item_dto.link,
        image: item_dto.image
      }
    end
  end
end
