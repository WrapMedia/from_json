class JsonForm::Form
  extend ActiveModel::Callbacks
  define_model_callbacks :save, :commit

  class_attribute :assigned_attributes
  self.assigned_attributes = []

  def self.attributes(*attributes)
    self.assigned_attributes += attributes
  end

  class_attribute :associations
  self.associations = {}

  def self.embeds_many(*args, **options, &block)
    associate JsonForm::EmbedsManyAssociation, *args, **options, &block
  end

  def self.embeds_one(*args, **options, &block)
    associate JsonForm::EmbedsOneAssociation, *args, **options, &block
  end

  def self.associate(association_class, name, form_class = JsonForm::Form, **options, &block)
    form_class = Class.new(form_class, &block) if block
    reflection = JsonForm::AssociationReflection.new(association_class, form_class, **options)
    self.associations = associations.merge(name => reflection)
  end

  def self.base(_)
    to_s.sub(/Form\z/, '').constantize
  end

  def self.form_for(_)
    self
  end

  def self.from_attributes(data = {}, options = {})
    base_class = options.delete(:base) || base(data)
    if data[:id]
      model = base_class.find_or_initialize_by(id: data[:id])
    else
      model = base_class.new
    end
    form_for(data).new(model, options).tap { |form| form.attributes = data }
  end

  attr_reader :model, :options

  def initialize(model, **options)
    @model = model
    @options = options
    @children_forms = []
    @parent_forms = []
  end

  def attributes=(data)
    data.each do |attr, value|
      attr = attr.to_s.underscore.to_sym
      if associations.key?(attr)
        reflection = associations[attr]
        forms = reflection.build(attr, @model, @options).assign(value)
        if reflection.options[:parent]
          @parent_forms.push *forms
        else
          @children_forms.push *forms
        end
      elsif assigned_attributes.include?(attr)
        @model.send("#{attr}=", value)
      end
    end
  end

  def save(raise: false)
    ActiveRecord::Base.transaction do
      run_callbacks :commit do
        persist(raise: raise)
      end
    end
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

  def save_forms(forms, raise: false)
    forms.each { |children_form| children_form.persist(raise: raise) }
  end

  def persist(raise: false)
    run_callbacks :save do
      save_forms @parent_forms, raise: raise
      if raise
        @model.save!
      else
        @model.save or raise ActiveRecord::Rollback
      end
      save_forms @children_forms, raise: raise
    end
  end
end
