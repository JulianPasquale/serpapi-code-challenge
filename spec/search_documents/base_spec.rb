# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/search_documents/base'

RSpec.describe SearchDocuments::Base do
  subject { described_class.parse('<html><body>test</body></html>') }

  describe '#carousel_elements_name' do
    it 'raises NotImplementedError' do
      expect do
        subject.carousel_elements_name
      end.to raise_error(NotImplementedError, 'Subclasses must implement this method')
    end
  end

  describe '#items_nodes' do
    it 'raises NotImplementedError' do
      expect { subject.items_nodes }.to raise_error(NotImplementedError, 'Subclasses must implement this method')
    end
  end
end
