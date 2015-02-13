class JsonForm::Form
  extend ActiveModel::Callbacks
  define_model_callbacks :save

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
    self.associations = associations.merge(name => [association_class, form_class])
  end

  attr_reader :model, :options

  def initialize(model, options = {})
    @model = model
    @options = options
    @children_forms = []
  end

  def attributes=(data)
    data.each do |attr, value|
      attr = attr.to_s.underscore.to_sym
      if associations.key?(attr)
        association_class, form_class = associations[attr]
        @children_forms.push *association_class.new(attr, @model, form_class, @options).assign(value)
      elsif assigned_attributes.include?(attr)
        @model.send("#{attr}=", value)
      end
    end
  end

  def save(raise: false)
    ActiveRecord::Base.transaction { persist(raise: raise) }
  end

  def save!
    save raise: true
  end

  def update_attributes(data)
    self.attributes = data
    save
  end

  def update_attributes!(data)
    self.attributes = data
    save!
  end

  protected

  def persist(raise: false)
    run_callbacks :save do
      @children_forms.each { |children_form| children_form.persist(raise: raise) }
      if raise
        @model.save!
      else
        @model.save or raise ActiveRecord::Rollback
      end
    end
  end
end
