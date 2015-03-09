class JsonForm::EmbedsOneAssociation < JsonForm::Association
  def assign(data)
    if data
      child_class = @parent.class.reflect_on_association(@name).klass
      form = @form_class.from_attributes(data, @form_options.merge(base: child_class))
      @parent.send("#{@name}=", form.model)
      form
    else
      @parent.send("#{@name}=", nil)
    end
  end
end
