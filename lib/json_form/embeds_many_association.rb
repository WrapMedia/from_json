class JsonForm::EmbedsManyAssociation < JsonForm::Association
  def assign(model, data)
    association = model.send(@name)

    data.each do |child_data|
      child = association.detect { |target| child_data[:id].to_s == target.id.to_s } || association.build(id: child_data[:id])
      @form_class.new(child).attributes = child_data
    end
  end
end
