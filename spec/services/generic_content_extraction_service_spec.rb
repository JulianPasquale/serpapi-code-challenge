# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/services/generic_content_extraction_service'

RSpec.describe GenericContentExtractionService do
  let(:van_gogh_html) { File.read('spec/fixtures/van-gogh-paintings.html') }
  let(:beatles_html) { File.read('spec/fixtures/the-beathes.html') }
  let(:harry_potter_html) { File.read('spec/fixtures/harry-potter.html') }

  describe '#extract_carousel' do
    context 'with Van Gogh paintings HTML' do
      let(:service) { described_class.new(van_gogh_html, content_type: 'artworks') }
      let(:carousel) { service.extract_carousel }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
      end

      it 'extracts multiple tiles' do
        expect(carousel.tiles.length).to be > 10
      end

      it 'extracts tiles with proper artwork data' do
        starry_night = carousel.tiles.find { |tile| tile.title.include?('Starry Night') }
        
        expect(starry_night).not_to be_nil
        expect(starry_night.title).to eq('The Starry Night')
        expect(starry_night.metadata).to include('1889')
        expect(starry_night.link).to include('google.com/search')
        expect(starry_night.content_type).to eq('artworks')
      end

      it 'includes metadata about the carousel' do
        expect(carousel.metadata[:carousel_type]).to eq('Artworks')
        expect(carousel.metadata[:content_type]).to eq('artworks')
      end

      it 'extracts titles correctly' do
        titles = carousel.tiles.map(&:title)
        expect(titles).to include('The Starry Night')
        expect(titles).to include('The Potato Eaters')
        expect(titles).to include('Van Gogh self-portrait')
      end

      it 'extracts years as metadata' do
        tiles_with_years = carousel.tiles.select { |tile| tile.metadata.any? }
        expect(tiles_with_years.length).to be > 20
        
        starry_night = carousel.tiles.find { |tile| tile.title.include?('Starry Night') }
        expect(starry_night.metadata).to include('1889')
      end

      it 'extracts Google search links' do
        tiles_with_links = carousel.tiles.select { |tile| tile.link }
        expect(tiles_with_links.length).to be > 20
        
        starry_night = carousel.tiles.find { |tile| tile.title.include?('Starry Night') }
        expect(starry_night.link).to start_with('https://www.google.com/search')
        expect(starry_night.link).to include('q=The+Starry+Night')
      end
    end

    context 'with Beatles albums HTML' do
      let(:service) { described_class.new(beatles_html, content_type: 'albums') }
      let(:carousel) { service.extract_carousel }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
      end

      it 'extracts multiple album tiles' do
        expect(carousel.tiles.length).to be > 10
      end

      it 'extracts tiles with proper album data' do
        abbey_road = carousel.tiles.find { |tile| tile.title == 'Abbey Road' }
        
        expect(abbey_road).not_to be_nil
        expect(abbey_road.title).to eq('Abbey Road')
        expect(abbey_road.metadata).to include('1969')
        expect(abbey_road.link).to include('google.com/search')
        expect(abbey_road.content_type).to eq('albums')
      end

      it 'includes metadata about the carousel' do
        expect(carousel.metadata[:carousel_type]).to eq('Albums')
        expect(carousel.metadata[:content_type]).to eq('albums')
      end

      it 'extracts album titles correctly' do
        titles = carousel.tiles.map(&:title)
        expect(titles).to include('Abbey Road')
        expect(titles).to include('Let It Be')
        expect(titles).to include('Revolver')
        expect(titles).to include('The Beatles')
      end

      it 'extracts release years as metadata' do
        abbey_road = carousel.tiles.find { |tile| tile.title == 'Abbey Road' }
        let_it_be = carousel.tiles.find { |tile| tile.title == 'Let It Be' }
        
        expect(abbey_road.metadata).to include('1969')
        expect(let_it_be.metadata).to include('1970')
      end
    end

    context 'with unparseable HTML' do
      let(:service) { described_class.new('<html><body>No carousel here</body></html>') }
      let(:carousel) { service.extract_carousel }

      it 'returns an empty carousel' do
        expect(carousel).to be_a(DTOs::Carousel)
        expect(carousel.tiles).to be_empty
        expect(carousel.empty?).to be true
      end
    end

    context 'with Harry Potter books HTML' do
      let(:service) { described_class.new(harry_potter_html, content_type: 'books') }
      let(:carousel) { service.extract_carousel }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
      end

      it 'extracts multiple book tiles' do
        expect(carousel.tiles.length).to be > 5
      end

      it 'extracts tiles with proper book data' do
        sorcerers_stone = carousel.tiles.find { |tile| tile.title.include?("Sorcerer's Stone") }
        
        expect(sorcerers_stone).not_to be_nil
        expect(sorcerers_stone.title).to eq("Harry Potter and the Sorcerer's Stone")
        expect(sorcerers_stone.link).to include('google.com/search')
        expect(sorcerers_stone.content_type).to eq('books')
      end

      it 'includes metadata about the carousel' do
        expect(carousel.metadata[:carousel_type]).to eq('Books')
        expect(carousel.metadata[:content_type]).to eq('books')
      end

      it 'extracts book titles correctly' do
        titles = carousel.tiles.map(&:title)
        expect(titles).to include("Harry Potter and the Sorcerer's Stone")
        expect(titles).to include("Harry Potter and the Chamber of Secrets")
        expect(titles).to include("Harry Potter and the Prisoner of Azkaban")
      end

      it 'extracts Google search links for books' do
        tiles_with_links = carousel.tiles.select { |tile| tile.link }
        expect(tiles_with_links.length).to be > 5
        
        sorcerers_stone = carousel.tiles.find { |tile| tile.title.include?("Sorcerer's Stone") }
        expect(sorcerers_stone.link).to start_with('https://www.google.com/search')
      end
    end
  end

  describe '#document_metadata' do
    context 'with Van Gogh HTML' do
      let(:service) { described_class.new(van_gogh_html, content_type: 'paintings') }

      it 'returns metadata with carousel type and content type' do
        metadata = service.document_metadata
        
        expect(metadata).to be_a(Hash)
        expect(metadata[:carousel_type]).to eq('Artworks')
        expect(metadata[:content_type]).to eq('paintings')
      end
    end

    context 'with Beatles HTML' do
      let(:service) { described_class.new(beatles_html, content_type: 'music') }

      it 'returns metadata with carousel type and content type' do
        metadata = service.document_metadata
        
        expect(metadata).to be_a(Hash)
        expect(metadata[:carousel_type]).to eq('Albums')
        expect(metadata[:content_type]).to eq('music')
      end
    end

    context 'with Harry Potter HTML' do
      let(:service) { described_class.new(harry_potter_html, content_type: 'books') }

      it 'returns metadata with carousel type and content type' do
        metadata = service.document_metadata
        
        expect(metadata).to be_a(Hash)
        expect(metadata[:carousel_type]).to eq('Books')
        expect(metadata[:content_type]).to eq('books')
      end
    end
  end

  describe 'private methods' do
    let(:service) { described_class.new(van_gogh_html, content_type: 'artworks') }

    describe '#construct_full_url' do
      it 'constructs full Google URLs from relative paths' do
        relative_url = '/search?q=test'
        full_url = service.send(:construct_full_url, relative_url)
        
        expect(full_url).to eq('https://www.google.com/search?q=test')
      end

      it 'returns absolute URLs unchanged' do
        absolute_url = 'https://example.com/test'
        result = service.send(:construct_full_url, absolute_url)
        
        expect(result).to eq(absolute_url)
      end

      it 'returns nil for invalid URLs' do
        invalid_url = 'javascript:alert(1)'
        result = service.send(:construct_full_url, invalid_url)
        
        expect(result).to be_nil
      end

      it 'returns nil for nil input' do
        result = service.send(:construct_full_url, nil)
        
        expect(result).to be_nil
      end
    end
  end
end