# frozen_string_literal: true

require_relative 'base'

module SearchDocuments
  class Google < Base
    def parseable?
      !css('[data-attrid^="kc:"]').empty?
    end

    # Return text like "Artworks" or "Music" or whatever the carousel contains
    def carousel_elements_name
      container = kc_nodes.first
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

    # Return a Nokogiri fragment with the specific portion of the document that contains the carousel
    def carousel_container
      # Look for carousel container using Google's data-attrid taxonomy pattern
      # This ensures we select only knowledge card type carousels with images and search links
      kc_nodes.each do |node|
        # Verify this container has both images and search links (avoid ads)
        has_search_links = !node.css('a[href*="search?"]').empty?

        return node if has_search_links
      end

      nil
    end

    private

    def kc_nodes
      @kc_nodes ||= css('[data-attrid^="kc:"]')
    end
  end
end
