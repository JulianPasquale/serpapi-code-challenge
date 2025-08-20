# frozen_string_literal: true

require_relative '../search_documents/google'
require_relative '../dtos/carousel'
require_relative '../dtos/tile'
require_relative '../dtos/image'

# Generic service for extracting content from HTML using our Google document parser
class GenericContentExtractionService
  def initialize(html_content, options = {})
    @html_content = html_content
    @options = options
    @document = SearchDocuments::Google.parse(html_content)
  end

  def extract_carousel
    return empty_carousel unless @document.parseable?

    tiles = extract_tiles_from_carousel
    metadata = document_metadata

    DTOs::Carousel.new(
      tiles: tiles,
      metadata: metadata
    )
  end

  def document_metadata
    {
      carousel_type: @document.carousel_elements_name,
      content_type: @options[:content_type]
    }
  end

  private

  def extract_tiles_from_carousel
    container = @document.carousel_container
    return [] unless container

    # Generic approach: look for semantic patterns within kc: containers
    carousel_items = find_carousel_items_in_container(container)
    
    carousel_items.map do |item|
      extract_tile_from_item(item)
    end.compact
  end

  def find_carousel_items_in_container(container)
    # Universal strategy: Find all search links within the carousel container
    # This works for all document types (Van Gogh, Beatles, Harry Potter)
    container.css('a[href*="search?"]')
  end

  def extract_tile_from_item(item)
    # Generic title extraction
    title = extract_title_from_item(item)
    return nil unless title && !title.empty?

    # Generic metadata extraction
    metadata_array = extract_metadata_from_item(item)

    # Generic link extraction
    link = extract_link_from_item(item)

    # Generic image extraction
    images = extract_images_from_item(item)

    DTOs::Tile.new(
      title: title,
      link: link,
      metadata: metadata_array,
      images: images,
      content_type: @options[:content_type]
    )
  end

  def extract_title_from_item(item)
    # Universal title extraction for search links
    
    # First try: Get text directly from the link (works for Van Gogh, Beatles)
    direct_text = item.text.strip
    if direct_text.length > 0
      return extract_title_from_text(direct_text)
    end
    
    # Second try: Look for nearby heading elements (works for Harry Potter)
    # Check parent and grandparent containers for headings
    current = item.parent
    3.times do
      break unless current
      
      heading = current.at_css('[role="heading"]')
      if heading
        heading_text = heading.text.strip
        return extract_title_from_text(heading_text) if heading_text.length > 0
      end
      
      current = current.parent
    end
    
    # Fallback: title attribute
    item['title'] if item['title'] && !item['title'].empty?
  end

  def extract_title_from_text(text)
    # Clean up whitespace and separate title from metadata (years)
    cleaned = text.gsub(/\s+/, ' ').strip
    
    # Remove trailing 4-digit years (common metadata pattern)
    cleaned.gsub(/\s+\d{4}$/, '').strip
  end

  def extract_metadata_from_item(item)
    # Look for text that looks like years, dates, or other metadata
    metadata = []
    
    item.css('*').each do |element|
      text = element.text.strip
      # Match 4-digit years
      if text.match?(/^\d{4}$/)
        metadata << text
      end
    end
    
    metadata.uniq
  end

  def extract_link_from_item(item)
    # Check if the item itself is a link
    if item.name == 'a' && item['href']
      return construct_full_url(item['href'])
    end
    
    # Otherwise look for a link within the item
    link_element = item.at_css('a[href]')
    link_element ? construct_full_url(link_element['href']) : nil
  end

  def extract_images_from_item(item)
    images = []
    
    item.css('img').each do |img|
      img_src = img['src'] || img['data-src']
      next unless img_src
      next if img_src.include?('data:image/gif') # Skip placeholder images
      
      images << DTOs::Image.new(src: img_src, alt: img['alt'])
    end
    
    images
  end

  def construct_full_url(href)
    return nil unless href
    
    if href.start_with?('/search')
      "https://www.google.com#{href}"
    elsif href.start_with?('http')
      href
    else
      nil
    end
  end

  def empty_carousel
    DTOs::Carousel.new(tiles: [], metadata: {})
  end
end