# JsonForm

Gem for creating Json forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'from_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install from_json

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
```
