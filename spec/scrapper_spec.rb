# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/scrapper'

RSpec.describe Scrapper do
  describe '#scrap' do
    context 'with Van Gogh paintings HTML' do
      let(:file_path) { 'spec/fixtures/van-gogh-paintings.html' }
      let(:expected_output) { File.read('spec/fixtures/outputs/van-gogh-paintings.json') }
      subject { described_class.new(file_path: file_path) }

      it 'returns JSON matching the expected output' do
        result = subject.scrap
        expect(result).to eq(expected_output)
      end
    end

    context 'with The Beatles HTML' do
      let(:file_path) { 'spec/fixtures/the-beatles.html' }
      let(:expected_output) { File.read('spec/fixtures/outputs/the-beatles.json') }
      subject { described_class.new(file_path: file_path) }

      it 'returns JSON matching the expected output' do
        result = subject.scrap
        expect(result).to eq(expected_output)
      end
    end

    context 'with Harry Potter HTML' do
      let(:file_path) { 'spec/fixtures/harry-potter.html' }
      let(:expected_output) { File.read('spec/fixtures/outputs/harry-potter.json') }
      subject { described_class.new(file_path: file_path) }

      it 'returns JSON matching the expected output' do
        result = subject.scrap
        expect(result).to eq(expected_output)
      end
    end

    context 'with different format parameter' do
      let(:file_path) { 'spec/fixtures/van-gogh-paintings.html' }

      it 'raises error for unsupported format' do
        scrapper = described_class.new(file_path: file_path, format: 'xml')
        expect { scrapper.scrap }.to raise_error('Format not supported')
      end
    end

    context 'with different engine parameter' do
      let(:file_path) { 'spec/fixtures/van-gogh-paintings.html' }

      it 'raises error for unsupported engine' do
        scrapper = described_class.new(file_path: file_path, engine: 'bing')
        expect { scrapper.scrap }.to raise_error('Engine not supported')
      end
    end
  end
end