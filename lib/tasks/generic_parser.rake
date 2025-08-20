# frozen_string_literal: true

namespace :content do
  desc 'Parse generic content from HTML file'
  task :parse, [:file_path, :formatter, :content_type] do |t, args|
    require_relative '../services/generic_content_extraction_service'
    require_relative '../formatters/json_formatter'

    # Default values
    file_path = args[:file_path] || 'files/van-gogh-paintings.html'
    formatter_type = args[:formatter] || 'json'
    content_type = args[:content_type] || 'generic'

    # Validate file exists
    unless File.exist?(file_path)
      puts "Error: File #{file_path} not found"
      exit 1
    end

    # Select formatter
    formatter = case formatter_type.downcase
                when 'json'
                  Formatters::JsonFormatter.new
                else
                  puts "Error: Unknown formatter '#{formatter_type}'. Available: json"
                  exit 1
                end

    # Parse the file
    puts "Parsing #{file_path} with #{formatter_type} formatter (content type: #{content_type})..."

    html_content = File.read(file_path)
    extraction_service = GenericContentExtractionService.new(
      html_content, {
        content_type: content_type
      }
    )

    carousel = extraction_service.extract_carousel
    metadata = extraction_service.document_metadata

    result = formatter.format(carousel.tiles, metadata: metadata)
    puts result

    # Print summary
    puts "\n--- Summary ---"
    puts "Extracted #{carousel.tile_count} tiles"
    puts "Search query: #{metadata[:search_query]}"
    puts "Content types: #{carousel.content_types.join(', ')}" unless carousel.content_types.empty?
    puts "Tiles with images: #{carousel.tiles_with_images.count}"
    puts "Tiles with metadata: #{carousel.tiles_with_metadata.count}"
  end

  desc 'Show parser statistics for a file'
  task :stats, [:file_path, :content_type] do |t, args|
    require_relative '../services/generic_content_extraction_service'

    file_path = args[:file_path] || 'files/van-gogh-paintings.html'
    content_type = args[:content_type] || 'generic'

    unless File.exist?(file_path)
      puts "Error: File #{file_path} not found"
      exit 1
    end

    html_content = File.read(file_path)
    extraction_service = GenericContentExtractionService.new(html_content, {
                                                               content_type: content_type
                                                             })

    carousel = extraction_service.extract_carousel
    metadata = extraction_service.document_metadata

    puts '=== Generic Content Parser Statistics ==='
    puts "File: #{file_path}"
    puts "Content Type: #{content_type}"
    puts "Search Query: #{metadata[:search_query]}"
    puts "HTML Version: #{metadata[:html_version]}"
    puts "Has Knowledge Graph: #{metadata[:has_knowledge_graph]}"
    puts "Total Content Nodes: #{metadata[:total_content]}"
    puts "Visible Content Nodes: #{metadata[:visible_content]}"
    puts "Successfully Extracted: #{carousel.tile_count}"
    puts "With Images: #{carousel.tiles_with_images.count}"
    puts "With Metadata: #{carousel.tiles_with_metadata.count}"

    puts "Content Types Found: #{carousel.content_types.join(', ')}" unless carousel.content_types.empty?

    if carousel.tiles_with_metadata.any?
      all_metadata = carousel.tiles_with_metadata.flat_map(&:metadata).compact
      puts "Sample Metadata: #{all_metadata.first(5).join(', ')}" unless all_metadata.empty?
    end
  end
end
