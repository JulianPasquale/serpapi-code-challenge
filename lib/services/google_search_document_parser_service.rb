# frozen_string_literal: true

require_relative 'generic_content_extraction_service'
require_relative '../formatters/artwork_formatter'

# Service for parsing Google search document HTML and formatting the extracted data
class GoogleSearchDocumentParserService
  def initialize(html_content, options = {})
    @html_content = html_content
    @options = options
    @extraction_service = GenericContentExtractionService.new(html_content, options)
    @formatter = Formatters::ArtworkFormatter.new
  end

  def extract_and_format
    carousel = extract_carousel
    metadata = { content_type: @options[:content_type] || 'artworks' }
    @formatter.format(carousel.tiles, metadata: metadata)
  end

  def extract_carousel
    @extraction_service.extract_carousel
  end

  def document_metadata
    @extraction_service.document_metadata
  end
end