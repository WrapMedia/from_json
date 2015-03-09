class JsonForm::AssociationReflection
  attr_reader :association_class, :form_class, :options

  def initialize(association_class, form_class, **options)
    @association_class = association_class
    @form_class = form_class
    @options = options
  end

  def build(name, model, **options)
    @association_class.new(name, model, form_class, options)
  end
end
