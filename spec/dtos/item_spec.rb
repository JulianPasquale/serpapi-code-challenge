# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/dtos/item'

RSpec.describe DTOs::Item do
  let(:name) { 'Test Item' }
  let(:extensions) { %w[extension1 extension2] }
  let(:link) { 'http://example.com/test' }
  let(:image) { 'http://example.com/image.jpg' }

  subject { described_class.new(name: name, extensions: extensions, link: link, image: image) }

  describe 'attributes' do
    it 'has correct name' do
      expect(subject.name).to eq(name)
    end

    it 'has correct extensions' do
      expect(subject.extensions).to eq(extensions)
    end

    it 'has correct link' do
      expect(subject.link).to eq(link)
    end

    it 'has correct image' do
      expect(subject.image).to eq(image)
    end
  end
end
