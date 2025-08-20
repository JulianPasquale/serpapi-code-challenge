# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/dtos/carousel'

RSpec.describe DTOs::Carousel do
  let(:item1) { DTOs::Item.new(name: 'Item 1', extensions: ['ext1'], link: 'http://example.com', image: 'image1.jpg') }
  let(:item2) { DTOs::Item.new(name: 'Item 2', extensions: ['ext2'], link: 'http://example.com', image: 'image2.jpg') }
  let(:item3) { DTOs::Item.new(name: 'Item 3', extensions: ['ext3'], link: 'http://example.com', image: 'image3.jpg') }

  describe '#items_count' do
    context 'with no items' do
      subject { described_class.new(title: 'Test', items: []) }
      
      it 'returns 0' do
        expect(subject.items_count).to eq(0)
      end
    end

    context 'with multiple items' do
      subject { described_class.new(title: 'Test', items: [item1, item2, item3]) }
      
      it 'returns the correct count' do
        expect(subject.items_count).to eq(3)
      end
    end

    context 'with nil items filtered out' do
      subject { described_class.new(title: 'Test', items: [item1, nil, item2, nil, item3]) }
      
      it 'returns count without nils' do
        expect(subject.items_count).to eq(3)
      end
    end
  end

  describe '#empty?' do
    context 'with no items' do
      subject { described_class.new(title: 'Test', items: []) }
      
      it 'returns true' do
        expect(subject.empty?).to be true
      end
    end

    context 'with items' do
      subject { described_class.new(title: 'Test', items: [item1]) }
      
      it 'returns false' do
        expect(subject.empty?).to be false
      end
    end

    context 'with only nil items' do
      subject { described_class.new(title: 'Test', items: [nil, nil]) }
      
      it 'returns true after filtering nils' do
        expect(subject.empty?).to be true
      end
    end
  end
end