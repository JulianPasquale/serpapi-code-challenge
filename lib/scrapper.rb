# frozen_string_literal: true

require_relative 'formatters/json_formatter'
require_relative 'services/carousel_extraction_service'

class Scrapper
  def initialize(file_path:, engine: 'google', format: 'json')
    @file_path = file_path
    @engine = engine
    @format = format
  end

  def scrap
    carousel = extraction_service.extract_carousel

    formatter.parse(carousel)
  end

  private

  def formatter
    @formatter ||=
      case @format
      when 'json'
        Formatters::JsonFormatter.new
      else
        raise 'Format not supported'
      end
  end

  def extraction_service
    @extraction_service ||= CarouselExtractionService.new(
      html_content: File.read(@file_path), engine: @engine
    )
  end
end
