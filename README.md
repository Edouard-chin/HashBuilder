### Installation

1) Add the `hash_builder` gem in your gemfile and run `bundle install` !
```ruby
# Gemfile
  gem 'hash_builder'
```
2) Include the module in your class and you are good to go!
```ruby
class Person
  include HashBuilder
end
```

The HashBuilder gem is a convenient way to deal with methods that returns a hash. Ever had something looking like this in your codebase? Then keep reading!

```ruby
  def my_hash
    data = {
      name: name,
      first_name: first_name,
      date_of_birth: {
        day: dob.day,
        year: dob.year,
        month: dob.month
      }
    }
    data[:preferred_food] = preferred_food if preferred_food.present?
    data[:preferred_animal] = preferred_animal if preferred_animal.present?
    # ...
  end
```
---------------
### Basic idea
You might have notice in the previous example, the hash keys maps to a method name `{ 'name': name }`. This is a very common situation, especially when you have a model that tries to mimic an external API.
The basic idea behind this gem is to lever ruby metaprograming by creating these methods dynamically.
Obviously adding a dependency only to deal with this example `{ 'name': name }` would be completely useless.
Things can becomes tricky when: 
- The hash keys maps to method on another object `{ 'dog_name': dog.name }`
- Or when they keys have prefixes/suffixes `{ 'prefered_food': food }`
- What about nested hash `{ personal_details: { name: name, first_name: first_name } }`
- If you want to conditionally add an element to the hash 
- etc...

The Hash Builder has a friendly DSL to deal with all the examples above
```ruby
hash_builder :first_name, :last_name, method_name: :person_data
hash_builder :name, :age, key_prefix: :dog_, delegate_to: :dog, method_name: :person_data
hash_builder :color, :length, accessor_prefix: :hair_, nest_under: :hairs, method_name: person_data

# Calling the `person_data` method will return this hash:
{
  first_name: 'John',
  last_name: 'Doe',
  dog_name: 'Billy',
  dog_age: 6,
  hairs: {
    color: 'black',
    length: 'short'
  }
}
```
----------------------------

### Configuration reference

> Affixes (key_prefix, key_suffix, accessor_prefix, accessor_suffix)
  - The key affixes will prefix or suffix your hash key
  - The accessor affixes will call method starting with the specified affix

```ruby
class Person
  include HashBuilder
  
  hash_builder :color, accessor_suffix: :_attribute, method_name: :color
  # { color: 'red' }
   
  hash_builder :pet, key_prefix: :favorite_, method_name: :pet
  # { favorite_pet: 'dog' }

  hash_builder :color, key_prefix: :preferred, accessor_suffix: :_attribute, method_name: :color_affix
  # { preferred_color: 'red' }
  def initialize
    @color_attribute = 'red'
    @pet = 'dog'
  end
end
```

> `from` option will allow you to map the key to any method

```ruby
hash_builder :data, from: :personal_informations, method_name: :data_hash

# you can even pass a method name defined by the hash builder
hash_builder :data, from: :color_affix
# { data: { preferred_color: 'red' } }
```

> `nest_under` will nest your hash under the key you like, a symbol or an array of symbols can be passed

```ruby
hash_builder :first_name, nest_under: :data, method_name: :personal_information
# { data: { first_name: 'John' } }
hash_builder :last_name, nest_under: [:api, :data, :personal_information], method_name: :data_for_api
# { api: { data: { personal_information: { last_name: 'Doe' } } } }
# The nesting can be as deep as you want!
```

> `delegate_to` allows you to delegate the method to another object

```ruby
class Person
  hash_builder :day, :month, :year, delegate_to: :date_object, method_name: :dob_data
  # { day: 30, month: 8, year: 1989 }

  def date_object
    Date.new(1989, 8, 30)
  end
end
```

> `if` to conditionally add the element to the hash, you can pass a symbol, or a proc. **If you pass a symbol**, hash builder will execute the condition on the hash value. If you pass a proc, the condition will get executed in the context of the class.

```ruby
class Person
  hash_builder :first_name, if: :present?, method_name: :symbol_condition
  # { } Empty hash is returned as the condition was not met
  # The condition is called on first_name ("".present?)

  hash_builder :last_name, if: ->(o) { o.wrestler? }, method_name: :proc_condition
  # { } Empty hash is returned as the condition was not met
  # The condition method is called on the class

  def initialize
    @first_name = ''
    @last_name = 'Doe'
  end

 def wrestler?
   false
 end
end
```
------------------------------
### Other

You can call multiple times hash_builder with the same method_name, this is usefull if you want to add options to specified keys:
```ruby
hash_builder :first_name, method_name: :info
hash_builder :last_name, if: :present?, method_name: :info
hash_builder :day, delegate_to: :dob, method_name: :info
# { first_name: 'Edouard', last_name: 'Doe', day: 30 }
```

ActiveSupport is the only dependency to avoid having the `method_name` repetition you can use the convenient `with_options`

```ruby
with_options method_name: :info do
  hash_builder :first_name,
  hash_builder :last_name, if: :present?
  hash_builder :age, delegate_to: :dob
end
```

### Contribute!
Contribution are very welcome!
- Fork the repo
- Create your feature branch (git checkout -b my-new-feature).
- Add tests for tour changes
- Open a PR
