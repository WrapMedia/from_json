class JsonForm::Association
  attr_reader :name, :form_class, :parent, :children_forms

  def initialize(name, parent, form_class, form_options)
    @name, @form_class, @parent, @form_options = name, form_class, parent, form_options
    @children_forms = []
  end
end
