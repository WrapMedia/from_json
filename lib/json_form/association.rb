class JsonForm::Association
  attr_reader :name, :form_class

  def initialize(name, form_class)
    @name, @form_class, @options = name, form_class
  end
end
