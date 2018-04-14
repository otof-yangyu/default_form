module DefaultForm::Builder::Default
  VALIDATIONS = [
    :required,
    :pattern,
    :min, :max, :step,
    :maxlength
  ]

  def default_value(method)
    if origin_on.autocomplete
      if object_name
        return params[object_name]&.fetch(method, '')
      else
        return params[method]
      end
    end
  end

  def default_step(method)
    if object.is_a?(ActiveRecord::Base)
      0.1.to_d.power(object.class.columns_hash[method.to_s]&.scale.to_i)
    else
    end
  end

  def default_placeholder(method)
    if object.is_a?(ActiveRecord::Base)
      object.class.human_attribute_name(method)
    else
      # todo
    end
  end

  def default_valid(options)
    valid_key = (options.keys & VALIDATIONS).sort.join('_')
    if valid_key.present?
      options[:onblur] ||= 'checkValidity()'
      options[:oninput] ||= 'clearValid(this)'
      options[:oninvalid] ||= 'valid' + valid_key.camelize + '(this)'
    end
    options
  end

  def custom_config(options)

  end

end
