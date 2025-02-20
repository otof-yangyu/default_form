module DefaultForm::ControllerHelper

  def self.prepended(model)

    def model.default_form_builder(builder, &block)
      builder = define_form_builder(builder, &block)
      super builder
    end

    def model.define_form_builder(builder, parent: DefaultForm::DefaultBuilder)
      builder_class = Class.new(parent)
      builder_class.config.on = ActiveSupport::OrderedOptions.new
      builder_class.config.css = ActiveSupport::OrderedOptions.new

      if block_given?
        yield builder_class.config
      end

      if builder.is_a? String
        if Object.const_defined?(builder)
          Object.send(:remove_const, builder)
        end
        Object.const_set builder, builder_class
      end
      builder_class
    end

  end

end

ActiveSupport.on_load :action_controller do
  prepend DefaultForm::ControllerHelper
end


