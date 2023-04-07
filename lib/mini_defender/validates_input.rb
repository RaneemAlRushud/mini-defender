# frozen_string_literal: true

module MiniDefender::ValidatesInput
  extend ActiveSupport::Concern

  def validate!(rules, coerced = false)
    data = cleanse_data(params.to_unsafe_hash.deep_stringify_keys)
    validator = MiniDefender::Validator.new(rules, data)
    validator.validate!
    coerced ? validator.coerced : validator.data
  end

  private

  def cleanse_data(data, depth = 1)
    return data if depth > 16

    case data
      when Array
        data.map{ |v| cleanse_data(v, depth + 1) }.reject(&:nil?)
      when Hash
        data.to_h{ |k, v| [k, cleanse_data(v, depth + 1)] }.compact
      when Numeric, TrueClass, FalseClass, NilClass
        data
      else
        data = data.to_s.strip
        data = nil if data == ''
        data
    end
  end
end
