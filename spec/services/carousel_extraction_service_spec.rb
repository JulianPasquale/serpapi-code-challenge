# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/services/carousel_extraction_service'

RSpec.describe CarouselExtractionService do
  let(:subject) { described_class.new(html_content: html_content) }

  describe '#extract_carousel' do
    let(:carousel) { subject.extract_carousel }

    context 'with Van Gogh paintings HTML' do
      let(:html_content) { File.read('spec/fixtures/van-gogh-paintings.html') }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
        expect(carousel.title).to eq('Artworks')
      end

      it 'extracts multiple items' do
        expect(carousel.items.length).to eq(47)
        starry_night = carousel.items.find { |item| item.name.include?('Starry Night') }

        expect(starry_night).not_to be_nil
        expect(starry_night.name).to eq('The Starry Night')
        expect(starry_night.extensions).to include('1889')
        expect(starry_night.link).to include('https://www.google.com/search')
        expect(starry_night.image).to include('data:image/jpeg;base64,')
      end
    end

    context 'with Beatles albums HTML' do
      let(:html_content) { File.read('spec/fixtures/the-beathes.html') }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
        expect(carousel.title).to eq('Albums')
      end

      it 'extracts multiple album items' do
        expect(carousel.items.length).to eq(12)
        abbey_road = carousel.items.find { |item| item.name == 'Abbey Road' }

        expect(abbey_road).not_to be_nil
        expect(abbey_road.name).to eq('Abbey Road')
        expect(abbey_road.extensions).to include('1969')
        expect(abbey_road.link).to include('https://www.google.com/search')
        expect(abbey_road.image).to include('data:image/jpeg;base64,')
      end
    end

    context 'with unparseable HTML' do
      let(:html_content) { '<html><body>No carousel here</body></html>' }

      it 'returns an empty carousel' do
        expect(carousel).to be_a(DTOs::Carousel)
        expect(carousel.items).to be_empty
        expect(carousel.empty?).to be true
      end
    end

    context 'with Harry Potter books HTML' do
      let(:html_content) { File.read('spec/fixtures/harry-potter.html') }

      it 'returns a Carousel DTO' do
        expect(carousel).to be_a(DTOs::Carousel)
        expect(carousel.title).to eq('Books')
      end

      it 'extracts items with proper book data' do
        expect(carousel.items.length).to eq(6)
        sorcerers_stone = carousel.items.find { |item| item.name.include?("Sorcerer's Stone") }

        expect(sorcerers_stone).not_to be_nil
        expect(sorcerers_stone.name).to eq("Harry Potter and the Sorcerer's Stone")
        expect(sorcerers_stone.extensions).to include('1997')
        expect(sorcerers_stone.link).to include('https://www.google.com/search')
        expect(sorcerers_stone.image).to include('data:image/jpeg;base64,')
      end
    end
  end
end
