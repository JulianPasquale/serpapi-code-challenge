# frozen_string_literal: true

module DTOs
  class Item
    attr_reader :name, :extensions, :link, :image

    def initialize(name:, extensions:, link:, image:)
      @name = name
      @extensions = extensions
      @link = link
      @image = image
    end
  end
end
