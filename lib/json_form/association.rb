class JsonForm::Association
  attr_reader :name, :form_class, :parent

  def initialize(name, parent, form_class, form_options)
    @name, @form_class, @parent, @form_options = name, form_class, parent, form_options
  end
end
