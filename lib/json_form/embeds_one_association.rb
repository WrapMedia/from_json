class JsonForm::EmbedsOneAssociation < JsonForm::Association
  def assign(model, data)
    child = model.send(@name) || model.send("build_#{@name}", id: data[:id])
    @form_class.new(child).attributes = data
  end
end
