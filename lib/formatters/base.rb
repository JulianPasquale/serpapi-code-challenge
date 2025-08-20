# frozen_string_literal: true

module Formatters
  class Base
    def parse(carousel)
      raise NotImplementedError, 'Subclasses must implement this method'
    end
  end
end
