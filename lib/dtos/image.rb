# frozen_string_literal: true

module DTOs
  class Image
    attr_reader :url, :data, :format

    def initialize(url: nil, data: nil, format: nil, src: nil, alt: nil)
      @url = url || src
      @data = data
      @format = determine_format(@url, format)
      @alt = alt
    end

    def base64_encoded?
      data&.start_with?('data:')
    end

    def external_url?
      url&.match?(%r{^https?://})
    end

    def serializable_data
      data || url
    end

    def present?
      !serializable_data.nil?
    end

    private

    def determine_format(image_url, explicit_format)
      return explicit_format if explicit_format

      case image_url
      when /\.jpe?g/i then 'jpeg'
      when /\.png/i then 'png'
      when /\.gif/i then 'gif'
      when /\.webp/i then 'webp'
      when %r{data:image/(\w+)} then Regexp.last_match(1)
      else 'unknown'
      end
    end
  end
end
