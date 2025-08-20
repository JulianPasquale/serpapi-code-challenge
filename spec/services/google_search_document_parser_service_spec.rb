# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/services/google_search_document_parser_service'
require 'json'

RSpec.describe GoogleSearchDocumentParserService do
  let(:van_gogh_html) { File.read('spec/fixtures/van-gogh-paintings.html') }
  let(:beatles_html) { File.read('spec/fixtures/the-beathes.html') }
  let(:harry_potter_html) { File.read('spec/fixtures/harry-potter.html') }

  describe '#extract_and_format' do
    context 'with Van Gogh paintings HTML' do
      let(:service) { described_class.new(van_gogh_html, content_type: 'artworks') }
      let(:result) { service.extract_and_format }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns valid JSON' do
        expect { JSON.parse(result) }.not_to raise_error
      end

      it 'returns the expected structure' do
        expect(parsed_result).to have_key('artworks')
        expect(parsed_result['artworks']).to be_an(Array)
      end

      it 'extracts multiple artworks' do
        expect(parsed_result['artworks'].length).to be > 20
      end

      it 'formats artworks with the expected fields' do
        starry_night = parsed_result['artworks'].find { |artwork| artwork['name'].include?('Starry Night') }
        
        expect(starry_night).not_to be_nil
        expect(starry_night).to have_key('name')
        expect(starry_night).to have_key('extensions')
        expect(starry_night).to have_key('link')
        
        expect(starry_night['name']).to eq('The Starry Night')
        expect(starry_night['extensions']).to include('1889')
        expect(starry_night['link']).to include('google.com/search')
      end

      it 'includes all expected Van Gogh paintings' do
        artwork_names = parsed_result['artworks'].map { |artwork| artwork['name'] }
        
        expect(artwork_names).to include('The Starry Night')
        expect(artwork_names).to include('The Potato Eaters')
        expect(artwork_names).to include('Van Gogh self-portrait')
        expect(artwork_names).to include('Sunflowers')
      end

      it 'formats extensions as arrays' do
        artworks_with_extensions = parsed_result['artworks'].select { |artwork| artwork['extensions'].any? }
        
        expect(artworks_with_extensions.length).to be > 20
        artworks_with_extensions.each do |artwork|
          expect(artwork['extensions']).to be_an(Array)
        end
      end

      it 'includes valid Google search links' do
        artworks_with_links = parsed_result['artworks'].select { |artwork| artwork['link'] }
        
        expect(artworks_with_links.length).to be > 20
        artworks_with_links.each do |artwork|
          expect(artwork['link']).to start_with('https://www.google.com/search')
        end
      end
    end

    context 'with Beatles albums HTML' do
      let(:service) { described_class.new(beatles_html, content_type: 'albums') }
      let(:result) { service.extract_and_format }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns valid JSON' do
        expect { JSON.parse(result) }.not_to raise_error
      end

      it 'returns the expected structure for albums' do
        expect(parsed_result).to have_key('albums')
        expect(parsed_result['albums']).to be_an(Array)
      end

      it 'extracts multiple albums' do
        expect(parsed_result['albums'].length).to be > 10
      end

      it 'formats albums with the expected fields' do
        abbey_road = parsed_result['albums'].find { |album| album['name'] == 'Abbey Road' }
        
        expect(abbey_road).not_to be_nil
        expect(abbey_road).to have_key('name')
        expect(abbey_road).to have_key('extensions')
        expect(abbey_road).to have_key('link')
        
        expect(abbey_road['name']).to eq('Abbey Road')
        expect(abbey_road['extensions']).to include('1969')
        expect(abbey_road['link']).to include('google.com/search')
      end

      it 'includes all expected Beatles albums' do
        album_names = parsed_result['albums'].map { |album| album['name'] }
        
        expect(album_names).to include('Abbey Road')
        expect(album_names).to include('Let It Be')
        expect(album_names).to include('Revolver')
        expect(album_names).to include('The Beatles')
        expect(album_names).to include('Help!')
      end
    end

    context 'with Harry Potter books HTML' do
      let(:service) { described_class.new(harry_potter_html, content_type: 'books') }
      let(:result) { service.extract_and_format }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns valid JSON' do
        expect { JSON.parse(result) }.not_to raise_error
      end

      it 'returns the expected structure for books' do
        expect(parsed_result).to have_key('books')
        expect(parsed_result['books']).to be_an(Array)
      end

      it 'extracts multiple books' do
        expect(parsed_result['books'].length).to be > 5
      end

      it 'formats books with the expected fields' do
        sorcerers_stone = parsed_result['books'].find { |book| book['name'].include?("Sorcerer's Stone") }
        
        expect(sorcerers_stone).not_to be_nil
        expect(sorcerers_stone).to have_key('name')
        expect(sorcerers_stone).to have_key('extensions')
        expect(sorcerers_stone).to have_key('link')
        
        expect(sorcerers_stone['name']).to eq("Harry Potter and the Sorcerer's Stone")
        expect(sorcerers_stone['extensions']).to be_an(Array)
        expect(sorcerers_stone['link']).to include('google.com/search')
      end

      it 'includes expected Harry Potter books' do
        book_names = parsed_result['books'].map { |book| book['name'] }
        
        expect(book_names).to include("Harry Potter and the Sorcerer's Stone")
        expect(book_names).to include("Harry Potter and the Chamber of Secrets")
        expect(book_names).to include("Harry Potter and the Prisoner of Azkaban")
      end
    end

    context 'with custom content type' do
      let(:service) { described_class.new(van_gogh_html, content_type: 'paintings') }
      let(:result) { service.extract_and_format }
      let(:parsed_result) { JSON.parse(result) }

      it 'uses the custom content type as the root key' do
        expect(parsed_result).to have_key('paintings')
        expect(parsed_result['paintings']).to be_an(Array)
      end
    end

    context 'with unparseable HTML' do
      let(:service) { described_class.new('<html><body>No carousel here</body></html>') }
      let(:result) { service.extract_and_format }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns empty results for unparseable content' do
        expect(parsed_result).to have_key('artworks')
        expect(parsed_result['artworks']).to be_empty
      end
    end
  end

  describe '#extract_carousel' do
    context 'with Van Gogh HTML' do
      let(:service) { described_class.new(van_gogh_html, content_type: 'artworks') }
      let(:carousel) { service.extract_carousel }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
      end

      it 'extracts tiles successfully' do
        expect(carousel.tiles.length).to be > 20
      end

      it 'includes proper metadata' do
        expect(carousel.metadata[:carousel_type]).to eq('Artworks')
        expect(carousel.metadata[:content_type]).to eq('artworks')
      end
    end

    context 'with Harry Potter HTML' do
      let(:service) { described_class.new(harry_potter_html, content_type: 'books') }
      let(:carousel) { service.extract_carousel }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
      end

      it 'extracts book tiles successfully' do
        expect(carousel.tiles.length).to be > 5
      end

      it 'includes proper metadata' do
        expect(carousel.metadata[:carousel_type]).to eq('Books')
        expect(carousel.metadata[:content_type]).to eq('books')
      end
    end
  end

  describe '#document_metadata' do
    context 'with Van Gogh HTML' do
      let(:service) { described_class.new(van_gogh_html, content_type: 'artworks') }
      let(:metadata) { service.document_metadata }

      it 'returns document metadata' do
        expect(metadata).to be_a(Hash)
        expect(metadata[:carousel_type]).to eq('Artworks')
        expect(metadata[:content_type]).to eq('artworks')
      end
    end

    context 'with Harry Potter HTML' do
      let(:service) { described_class.new(harry_potter_html, content_type: 'books') }
      let(:metadata) { service.document_metadata }

      it 'returns document metadata' do
        expect(metadata).to be_a(Hash)
        expect(metadata[:carousel_type]).to eq('Books')
        expect(metadata[:content_type]).to eq('books')
      end
    end
  end

  describe 'integration with expected format' do
    let(:expected_array_url) { 'https://raw.githubusercontent.com/serpapi/code-challenge/master/files/expected-array.json' }
    let(:service) { described_class.new(van_gogh_html, content_type: 'artworks') }
    let(:result) { service.extract_and_format }
    let(:parsed_result) { JSON.parse(result) }

    it 'matches the expected array structure' do
      # Verify the structure matches expected-array.json format
      expect(parsed_result).to have_key('artworks')
      
      first_artwork = parsed_result['artworks'].first
      expect(first_artwork).to have_key('name')
      expect(first_artwork).to have_key('extensions') 
      expect(first_artwork).to have_key('link')
      
      expect(first_artwork['extensions']).to be_an(Array)
    end

    it 'extracts The Starry Night with correct data' do
      starry_night = parsed_result['artworks'].find { |artwork| artwork['name'] == 'The Starry Night' }
      
      expect(starry_night).not_to be_nil
      expect(starry_night['name']).to eq('The Starry Night')
      expect(starry_night['extensions']).to include('1889')
      expect(starry_night['link']).to start_with('https://www.google.com/search')
      expect(starry_night['link']).to include('q=The+Starry+Night')
    end
  end
end