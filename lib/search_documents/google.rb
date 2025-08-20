# frozen_string_literal: true

require_relative 'base'

module SearchDocuments
  class Google < Base
    def parseable?
      !kc_node.nil?
    end

    # Return text like "Artworks" or "Music" or whatever the carousel contains
    def carousel_elements_name
      container = kc_node
      while container
        # Look for heading elements within this container
        if (heading = container.at_css('[aria-level="2"][role="heading"]'))
          text = heading.text.strip
          return text unless text.empty?
        end

        # Move up to parent to continue search
        container = container.parent
      end
    end

    def items_nodes
      @items_nodes ||= kc_node.css('a[href*="search?"]')
    end

    private

    def kc_node
      @kc_node ||= at_css('[data-attrid^="kc:"]')
    end
  end
end
