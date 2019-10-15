# frozen_string_literal: true

module DefaultForm::ModelHelper

  def options_i18n(attribute)
    h = I18n.t enum_key(attribute), default: {}

    if h.is_a?(Hash) && h.present?
      return h.invert
    end

    if h.blank?
      name = attribute.to_s.pluralize
      if respond_to?(name)
        enum_hash = public_send(name)
        h = enum_hash.keys.map { |i| [i.humanize, i] }.to_h
      end
    end

    h
  end

  def enum_options_for_select(enum_name)
    enum_name = enum_name.to_s
    h = I18n.t enum_key(enum_name), default: nil

    if h
      h.stringify_keys.invert
    else
      enum_definition = defined_enums[enum_name.to_s]
      enum_definition.each_with_object({}) { |(label, _value), h| h[label.humanize] = label }
    end
  end

  def help_i18n(attribute)
    return nil if attribute.blank?
    help_key = DefaultForm.config.help_key.call(self, attribute)
    I18n.t help_key, default: nil
  end

  def enum_i18n(attribute, value)
    h = I18n.t enum_key(attribute)

    v = nil
    if h.is_a?(Hash)
      v = h[value] ? h[value] : h[value.to_s.to_sym]
    end

    if v.nil? && value.blank?
      v = value.to_s
    end

    if v.nil?
      v = human_attribute_name(value)
    end

    v
  end

  def enum_key(attribute)
    DefaultForm.config.enum_key.call(self, attribute)
  end

  def extract_multi_params(pairs)
    _pairs = pairs.select { |k, _| k.include?('(') }

    self.new.send :extract_callstack_for_multiparameter_attributes, _pairs
  end

  def self.extended(mod)
    mod.attribute_method_suffix '_i18n'

    mod.class_exec do
      def attribute_i18n(attr)
        if [:json, :jsonb].include? self.class.columns_hash[attr]&.type
          send(attr)&.transform_keys! { |key| self.class.human_attribute_name(key) }
        else
          self.class.enum_i18n attr, send(attr)
        end
      end
    end
  end

end

ActiveSupport.on_load :active_record do
  extend DefaultForm::ModelHelper
end
