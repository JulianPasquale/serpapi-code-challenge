# frozen_string_literal: true

require_relative '../search_documents/google'
require_relative '../dtos/carousel'
require_relative '../dtos/item'

class CarouselExtractionService
  def initialize(html_content:, engine: 'google')
    @html_content = html_content
    @engine = engine
  end

  def extract_carousel
    return empty_carousel unless document.parseable?

    DTOs::Carousel.new(
      title: document.carousel_elements_name,
      items: extract_items_from_carousel
    )
  end

  private

  def document
    @document ||=
      case @engine
      when 'google'
        SearchDocuments::Google.parse(@html_content)
      else
        raise 'Engine not supported'
      end
  end

  def extract_items_from_carousel
    nodes = document.items_nodes
    return [] if nodes.empty?

    nodes.filter_map(&method(:item_to_dto))
  end

  def item_to_dto(item)
    name, extensions = find_name_and_extensions(item.at_css('div') || item.parent.at_css('div'))

    DTOs::Item.new(
      name: name,
      extensions: Array(extensions).flatten.compact,
      link: link_from_item(item),
      image: image_from_item(item)
    )
  end

  def find_name_and_extensions(item)
    result = item.children.filter_map do |child|
      next unless child.element?

      extracted_text = child.text.strip.split.join(' ')
      extracted_text.empty? ? nil : extracted_text
    end.last(2)

    return result unless result.empty?

    find_name_and_extensions(item.next) unless item.next.nil?
  end

  def link_from_item(item)
    link_element = item.name == 'a' && item['href'] ? item : item.at_css('a[href]')

    return unless link_element

    construct_full_url(link_element['href'])
  end

  def image_from_item(item)
    img = item.at_css('img') || item.parent.at_css('img')
    return unless img

    img_src = img['src'] || img['data-src']
    return unless img_src

    # Check if this is a deferred image that needs script lookup
    return find_image_from_script(img['id']) if img['data-deferred'] == '1'

    img_src
  end

  def find_image_from_script(img_id)
    return nil if img_id.nil? || img_id.empty?

    document.css('script').each do |script|
      content = script.content.to_s

      # Look for pattern: var ii = ['image_id']; _setImagesSrc(ii, s);
      # where s contains the base64 image data
      next unless content.include?(img_id)

      match = content.match(%r{var s = '(data:image/[^']+)'.*var ii = \['#{Regexp.escape(img_id)}'\]})

      return match[1] if match
    end

    nil
  end

  def construct_full_url(href)
    return nil unless href

    return href if href.start_with?('http')

    "https://www.google.com#{href}"
  end

  def empty_carousel
    DTOs::Carousel.new
  end
end
