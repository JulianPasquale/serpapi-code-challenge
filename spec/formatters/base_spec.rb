# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/formatters/base'
require_relative '../../lib/dtos/carousel'

RSpec.describe Formatters::Base do
  subject { described_class.new }

  describe '#parse' do
    it 'raises NotImplementedError' do
      expect do
        subject.parse(DTOs::Carousel.new)
      end.to raise_error(NotImplementedError, 'Subclasses must implement this method')
    end
  end
end
