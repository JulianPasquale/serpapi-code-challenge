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

  describe '#items_nodes' do
    context 'with Van Gogh paintings HTML' do
      let(:html_content) { File.read('spec/fixtures/van-gogh-paintings.html') }
      it 'returns carousel items nodes' do
        items = subject.items_nodes
        expect(items).to be_a(Nokogiri::XML::NodeSet)
        expect(items.length).to eq(47)
      end
    end

    context 'with The Beatles HTML' do
      let(:html_content) { File.read('spec/fixtures/the-beathes.html') }

      it 'returns carousel items nodes' do
        items = subject.items_nodes
        expect(items).to be_a(Nokogiri::XML::NodeSet)
        expect(items.length).to eq(12)
      end
    end

    context 'with Harry Potter HTML' do
      let(:html_content) { File.read('spec/fixtures/harry-potter.html') }

      it 'returns carousel items nodes' do
        items = subject.items_nodes
        expect(items).to be_a(Nokogiri::XML::NodeSet)
        expect(items.length).to eq(6)
      end
    end
  end
end
