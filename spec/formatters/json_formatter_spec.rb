# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/formatters/json_formatter'
require_relative '../../lib/dtos/carousel'
require_relative '../../lib/dtos/item'

RSpec.describe Formatters::JsonFormatter do
  let(:item1) { DTOs::Item.new(name: 'Item 1', extensions: %w[ext1 ext2], link: 'http://example.com/1', image: 'image1.jpg') }
  let(:item2) { DTOs::Item.new(name: 'Item 2', extensions: ['ext3'], link: 'http://example.com/2', image: 'image2.jpg') }
  let(:carousel) { DTOs::Carousel.new(title: 'Test Carousel', items: [item1, item2]) }

  subject { described_class.new }

  describe '#parse' do
    context 'with a carousel containing items' do
      let(:result) { subject.parse(carousel) }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns valid JSON' do
        expect { JSON.parse(result) }.not_to raise_error
      end

      it 'uses carousel title as root key' do
        expect(parsed_result).to have_key('test carousel')
      end

      it 'includes all items' do
        items = parsed_result['test carousel']
        expect(items.length).to eq(2)
      end

      it 'formats items correctly' do
        items = parsed_result['test carousel']

        expect(items[0]).to eq({
                                 'name' => 'Item 1',
                                 'extensions' => %w[ext1 ext2],
                                 'link' => 'http://example.com/1',
                                 'image' => 'image1.jpg'
                               })

        expect(items[1]).to eq({
                                 'name' => 'Item 2',
                                 'extensions' => ['ext3'],
                                 'link' => 'http://example.com/2',
                                 'image' => 'image2.jpg'
                               })
      end
    end

    context 'with empty carousel' do
      let(:empty_carousel) { DTOs::Carousel.new(title: 'Empty', items: []) }
      let(:result) { subject.parse(empty_carousel) }
      let(:parsed_result) { JSON.parse(result) }

      it 'returns valid JSON with empty array' do
        expect(parsed_result).to eq({ 'empty' => [] })
      end
    end
  end
end
