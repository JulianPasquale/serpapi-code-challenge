# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/formatters/artwork_formatter'
require_relative '../../lib/dtos/tile'
require_relative '../../lib/dtos/image'
require 'json'

RSpec.describe Formatters::ArtworkFormatter do
  let(:formatter) { described_class.new }

  describe '#format' do
    let(:image) { DTOs::Image.new(src: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABA...', alt: 'Test Image') }
    let(:tile_with_image) do
      DTOs::Tile.new(
        title: 'The Starry Night',
        link: 'https://www.google.com/search?q=The+Starry+Night',
        metadata: ['1889'],
        images: [image],
        content_type: 'artwork'
      )
    end
    
    let(:tile_without_image) do
      DTOs::Tile.new(
        title: 'Abbey Road',
        link: 'https://www.google.com/search?q=Abbey+Road',
        metadata: ['1969'],
        images: [],
        content_type: 'album'
      )
    end

    let(:tile_no_metadata) do
      DTOs::Tile.new(
        title: 'Untitled',
        link: 'https://www.google.com/search?q=Untitled',
        metadata: [],
        images: [],
        content_type: 'artwork'
      )
    end

    context 'with default content type' do
      let(:tiles) { [tile_with_image, tile_without_image] }
      let(:result) { formatter.format(tiles) }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns valid JSON' do
        expect { JSON.parse(result) }.not_to raise_error
      end

      it 'uses "artworks" as the default root key' do
        expect(parsed_result).to have_key('artworks')
        expect(parsed_result['artworks']).to be_an(Array)
      end

      it 'formats tiles with all required fields' do
        artwork = parsed_result['artworks'].first
        
        expect(artwork).to have_key('name')
        expect(artwork).to have_key('extensions')
        expect(artwork).to have_key('link')
        
        expect(artwork['name']).to eq('The Starry Night')
        expect(artwork['extensions']).to eq(['1889'])
        expect(artwork['link']).to eq('https://www.google.com/search?q=The+Starry+Night')
      end

      it 'includes image data when present' do
        artwork_with_image = parsed_result['artworks'].find { |a| a['name'] == 'The Starry Night' }
        artwork_without_image = parsed_result['artworks'].find { |a| a['name'] == 'Abbey Road' }
        
        expect(artwork_with_image).to have_key('image')
        expect(artwork_with_image['image']).to eq('data:image/jpeg;base64,/9j/4AAQSkZJRgABA...')
        
        expect(artwork_without_image).not_to have_key('image')
      end

      it 'handles empty metadata correctly' do
        tiles_with_empty_metadata = [tile_no_metadata]
        result = formatter.format(tiles_with_empty_metadata)
        parsed_result = JSON.parse(result)
        
        artwork = parsed_result['artworks'].first
        expect(artwork['extensions']).to eq([])
      end
    end

    context 'with custom content type in metadata' do
      let(:tiles) { [tile_with_image] }
      let(:metadata) { { content_type: 'paintings' } }
      let(:result) { formatter.format(tiles, metadata: metadata) }
      let(:parsed_result) { JSON.parse(result) }

      it 'uses the custom content type as root key' do
        expect(parsed_result).to have_key('paintings')
        expect(parsed_result['paintings']).to be_an(Array)
        expect(parsed_result).not_to have_key('artworks')
      end

      it 'formats the content correctly under the custom key' do
        painting = parsed_result['paintings'].first
        
        expect(painting['name']).to eq('The Starry Night')
        expect(painting['extensions']).to eq(['1889'])
        expect(painting['link']).to eq('https://www.google.com/search?q=The+Starry+Night')
        expect(painting['image']).to eq('data:image/jpeg;base64,/9j/4AAQSkZJRgABA...')
      end
    end

    context 'with albums content type' do
      let(:tiles) { [tile_without_image] }
      let(:metadata) { { content_type: 'albums' } }
      let(:result) { formatter.format(tiles, metadata: metadata) }
      let(:parsed_result) { JSON.parse(result) }

      it 'uses "albums" as the root key' do
        expect(parsed_result).to have_key('albums')
        expect(parsed_result['albums']).to be_an(Array)
      end

      it 'formats album data correctly' do
        album = parsed_result['albums'].first
        
        expect(album['name']).to eq('Abbey Road')
        expect(album['extensions']).to eq(['1969'])
        expect(album['link']).to eq('https://www.google.com/search?q=Abbey+Road')
        expect(album).not_to have_key('image')
      end
    end

    context 'with books content type' do
      let(:book_tile) do
        DTOs::Tile.new(
          title: 'Harry Potter and the Cursed Child',
          link: 'https://www.google.com/search?q=Harry+Potter+Cursed+Child',
          metadata: [],
          images: [],
          content_type: 'book'
        )
      end
      let(:tiles) { [book_tile] }
      let(:metadata) { { content_type: 'books' } }
      let(:result) { formatter.format(tiles, metadata: metadata) }
      let(:parsed_result) { JSON.parse(result) }

      it 'uses "books" as the root key' do
        expect(parsed_result).to have_key('books')
        expect(parsed_result['books']).to be_an(Array)
      end

      it 'formats book data correctly' do
        book = parsed_result['books'].first
        
        expect(book['name']).to eq('Harry Potter and the Cursed Child')
        expect(book['extensions']).to eq([])
        expect(book['link']).to eq('https://www.google.com/search?q=Harry+Potter+Cursed+Child')
        expect(book).not_to have_key('image')
      end
    end

    context 'with empty tiles array' do
      let(:tiles) { [] }
      let(:result) { formatter.format(tiles) }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns empty array for artworks' do
        expect(parsed_result['artworks']).to eq([])
      end
    end

    context 'with nil tiles' do
      let(:result) { formatter.format(nil) }
      let(:parsed_result) { JSON.parse(result) }

      it 'handles nil gracefully' do
        expect(parsed_result['artworks']).to eq([])
      end
    end

    context 'with multiple tiles of different types' do
      let(:tiles) { [tile_with_image, tile_without_image, tile_no_metadata] }
      let(:result) { formatter.format(tiles) }
      let(:parsed_result) { JSON.parse(result) }

      it 'formats all tiles correctly' do
        expect(parsed_result['artworks'].length).to eq(3)
        
        names = parsed_result['artworks'].map { |a| a['name'] }
        expect(names).to include('The Starry Night', 'Abbey Road', 'Untitled')
      end

      it 'handles different metadata lengths' do
        extensions = parsed_result['artworks'].map { |a| a['extensions'] }
        
        expect(extensions).to include(['1889'])  # tile_with_image
        expect(extensions).to include(['1969'])  # tile_without_image  
        expect(extensions).to include([])        # tile_no_metadata
      end
    end

    context 'integration with expected JSON structure' do
      let(:tiles) do
        [
          DTOs::Tile.new(
            title: 'The Starry Night',
            link: 'https://www.google.com/search?q=The+Starry+Night',
            metadata: ['1889'],
            images: [DTOs::Image.new(src: 'data:image/jpeg;base64,/9j/test')],
            content_type: 'artwork'
          ),
          DTOs::Tile.new(
            title: 'Van Gogh self-portrait',
            link: 'https://www.google.com/search?q=Van+Gogh+self-portrait',
            metadata: ['1889'],
            images: [],
            content_type: 'artwork'
          )
        ]
      end
      
      let(:result) { formatter.format(tiles) }
      let(:parsed_result) { JSON.parse(result) }

      it 'matches the expected-array.json structure exactly' do
        expect(parsed_result).to have_key('artworks')
        expect(parsed_result['artworks']).to be_an(Array)
        expect(parsed_result['artworks'].length).to eq(2)
        
        first_artwork = parsed_result['artworks'].first
        expect(first_artwork).to have_key('name')
        expect(first_artwork).to have_key('extensions')
        expect(first_artwork).to have_key('link')
        expect(first_artwork).to have_key('image')
        
        expect(first_artwork['name']).to eq('The Starry Night')
        expect(first_artwork['extensions']).to eq(['1889'])
        expect(first_artwork['link']).to start_with('https://www.google.com/search')
        expect(first_artwork['image']).to eq('data:image/jpeg;base64,/9j/test')
      end
    end
  end
end