# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/search_documents/google'

RSpec.describe SearchDocuments::Google do
  subject { described_class.parse(html_content) }

  describe '#carousel_elements_name' do
    context 'with Van Gogh paintings HTML' do
      let(:html_content) { File.read('spec/fixtures/van-gogh-paintings.html') }
      it 'returns "Artworks"' do
        expect(subject.carousel_elements_name).to eq('Artworks')
      end
    end

    context 'with The Beatles HTML' do
      let(:html_content) { File.read('spec/fixtures/the-beathes.html') }

      it 'returns "Albums"' do
        expect(subject.carousel_elements_name).to eq('Albums')
      end
    end

    context 'with Harry Potter HTML' do
      let(:html_content) { File.read('spec/fixtures/harry-potter.html') }
      it 'returns "Books"' do
        expect(subject.carousel_elements_name).to eq('Books')
      end
    end
  end

  describe '#carousel_container' do
    context 'with Van Gogh paintings HTML' do
      let(:html_content) { File.read('spec/fixtures/van-gogh-paintings.html') }
      it 'returns a Nokogiri element with the expected data attribute' do
        container = subject.carousel_container
        expect(container).to be_a(Nokogiri::XML::Element)
        expect(container['data-attrid']).to eq('kc:/visual_art/visual_artist:works')
      end
    end

    context 'with The Beatles HTML' do
      let(:html_content) { File.read('spec/fixtures/the-beathes.html') }

      it 'returns the first carousel type for Beatles search' do
        container = subject.carousel_container
        expect(container).to be_a(Nokogiri::XML::Element)
        expect(container['data-attrid']).to eq('kc:/music/artist:albums')
      end
    end

    context 'with Harry Potter HTML' do
      let(:html_content) { File.read('spec/fixtures/harry-potter.html') }

      it 'returns the first carousel type for Beatles search' do
        container = subject.carousel_container
        expect(container).to be_a(Nokogiri::XML::Element)
        expect(container['data-attrid']).to eq('kc:/book/literary_series:books')
      end
    end
  end
end
