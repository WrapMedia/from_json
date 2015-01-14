class JsonForm::Form
  delegate :save, :save!, to: :@model

    class_attribute :assigned_attributes
    self.assigned_attributes = []

    def self.attributes(*attributes)
      self.assigned_attributes += attributes
    end

    class_attribute :associations
    self.associations = {}

    def self.embeds_many(*args, &block)
      associate JsonForm::EmbedsManyAssociation, *args, &block
    end

    def self.embeds_one(*args, &block)
      associate JsonForm::EmbedsOneAssociation, *args, &block
    end

    def self.associate(association_class, name, form_class = JsonForm::Form, &block)
      form_class = Class.new(form_class, &block) if block
      self.associations = associations.merge(name => association_class.new(name, form_class))
    end

    def initialize(model)
      @model = model
    end

    def attributes=(data)
      data.each do |attr, value|
        attr = attr.to_s.underscore.to_sym
        if associations.key?(attr)
          associations[attr].assign(@model, value)
        elsif assigned_attributes.include?(attr)
          @model.send("#{attr}=", value)
        end
      end
    end

    def update_attributes(data)
      self.attributes = data
      save
    end
end
