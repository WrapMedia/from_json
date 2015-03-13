# JsonForm

Gem for creating Json forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_form'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_form

## Usage

Each form is a separate class. You will have to inherit your forms from JsonForm::Form, example:

```ruby
class MyModelForm < JsonForm::Form
  attributes :name, :size

  embeds_many :children, ChildForm
  embeds_one :parent do
    attributes :length
  end
end

# Update @model from params[:model] and raises error if it's invalid
MyModelForm.new(@model).update_attributes!(params[:model])

# Update @model from params[:model] and returns false if it's invalid
MyModelForm.new(@model).update_attributes(params[:model])

# Or use a longer form for more precise control
form = MyModelForm.new(@model)
form.attributes = params[:model]
form.save! # or .save
```

## Automatically instantiate model

MyModelForm can automatically instantiate model using MyModel as base. So:

```ruby
form = MyModelForm.from_attributes(params[:model) # => #<MyModelForm:0x00000000>
form.model #=> #<MyModel:0x00000001>
form.save! # Persists changes from params[:model]
```

The logic behind auto initialization is:

1. Find model within database by `data[:id]` if it exists
2. Initialize new model instance with that id if it doesn't

In fact similar logic is used for associations too.

### Customizing behavior

You can change what model class is used by passing `:base` option to `.from_attributes` method. If some form should
always use different class, you can override `Form.base` method to return different class. Associations can be used as
base instead of classes too:

```ruby
form = MyModelForm.from_attributes(params[:model], base: current_user.my_models)
current_user.my_models == [form.model] # => true
```

You can also override `Form.form_for` method to return different form class when using `.from_attributes`. This is very
useful when dealing with STI models.

## Attributes

You can use `.attributes` method to add attributes that should be assigned from passed parameters essentially
whitelisting. That's why you don't need to use strong_parameters with forms at all and can directly pass
`params[:my_model]`.

Parameters are also automatically underscored:

```ruby
class MyModelForm < JsonForm::Form
  attributes :full_name
end

MyModelForm.new(@model).update_attributes!(fullName: 'John Doe')
@model.full_name # => 'John Doe'
```

For more control over params, you can override `Form#atrributes=` method and do whatever you want with the data passed.

## Associations

Forms support multiple association types: `embeds_many`, `embeds_one` and custom associations. Note that they are called
embeds_one and embeds_many specifically because they're different from Rails associations. They imply nested data:

```ruby
class ImageForm
  attributes :url
end

class ComponentForm
  embeds_one :image, ImageForm
end

ComponentForm.new(@component).update_attributes!(image: {id: @image.id, url: params[:url})
@component.image # => @image
@component.image.url # => params[:url]
```

You can also customize form that is used inline:

```ruby
class ShapeForm
  embeds_many :lines do
    attributes :x1, :y1, :x2, :y2
  end
end
```

### Custom associations

You can use custom associations to better control what happens with associations. These are very useful when dealing
with more complex associations (eg. STI objects in association). The usual way is to inherit your custom association
from `JsonForm::EmbedsManyAssociation` or `JsonForm::EmbedsOneAssociation` (but you can write your custom class from
scratch, just make sure it implements `#assign` method which returns an array of forms):

```ruby
class TasksAssociation < JsonForm::EmbedsManyAssociation
end

class EmployeeForm
  associate TasksAssociation, :tasks
end
```

### Options

You can pass options to associations. This is mostly usefull for you own custom associations. The only option that
standard associations support is `:parent`. If true this association will be saved before form itself to make sure that
parent object is saved before child:

```ruby
class EmployeeForm
  embeds_one :leader, parent: true
  embeds_one :task
end

EmployeeForm.new(@employee).save! # Will call @employee.leader.save! then @employee.save! then @employee.task.save!
```

## Form options

You can pass options when initializing form:

```ruby
EmployeeForm.new(@employee, skip_task_name: true)
```

You can reach options within `#attributes=` method or anywhere else through @options. These options will be passed to
embeded forms too, so it's very usefull to control what can be changed in children forms from parent forms. Just make
sure all your option names are unique (`:skip_task_name` is good, but `:skip_name` would be bad as it's too generic
and could potentially cause bad behavior when passed down the chain).

## Callbacks

You can define `before_save` and `after_save` callbacks in forms. Make use of those instead of using them in your models
since callbacks defined in forms can be easily bypassed if you don't need them by not using that form.
