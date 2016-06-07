require 'test_helper'
require 'byebug'
require 'models/warrior'
require 'models/dragon'
require 'models/human'
require 'models/animal'

class HashBuilderTest < Minitest::Test
  def setup
    @warrior = Warrior.new(100, 'John Cena', 'M', 'Very fast', 'Troll', 'Kirikou')
    @human = Human.new(
      Date.new(1989, 8, 30),
      'Chicken',
      'Monopoly',
      'Stargate',
      '70kg',
      '185cm',
      'Male'
    )
    @dragon = Dragon.new('Blue', 'Very solid', 42, 'Dothracus', 'Humans')
    @animal = Animal.new('Billy', 'dog', 'Mixed', 19, 'black', 'chicken', 'ball')
  end

  def test_hash_builder_basic
    assert_equal 100, @warrior.basic_info[:health]
    assert_equal 'John Cena', @warrior.basic_info[:name]
    assert_equal 'M', @warrior.basic_info[:gender]
    assert_equal 'Very fast', @warrior.basic_info[:speed]
  end

  def test_hash_builder_called_multiple_times_with_same_method_name
    expected = {
      'type' => 'dog',
      'race' => 'Mixed',
      'advanced' => {
        'age' => 19,
        'color' => 'black'
      }
    }
    assert_equal expected, @animal.advanced_properties
  end

  def test_hash_builder_after_modifying_attributes
    @warrior.tap do |o|
      o.health = 90
      o.name   = 'Sonya'
      o.gender = 'F'
      o.speed  = 'Fast'
    end

    assert_equal 90, @warrior.basic_info[:health]
    assert_equal 'Sonya', @warrior.basic_info[:name]
    assert_equal 'F', @warrior.basic_info[:gender]
    assert_equal 'Fast', @warrior.basic_info[:speed]
  end

  def test_hash_builder_returns_an_hash_with_indifferent_access
    assert_instance_of ActiveSupport::HashWithIndifferentAccess, @warrior.basic_info
  end

  def test_multiple_hash_builders
    assert_equal 'Blue', @dragon.skin[:color]
    assert_equal 'Very solid', @dragon.skin[:armor]

    assert_equal 42, @dragon.basic_info[:age]
    assert_equal 'Dothracus', @dragon.basic_info[:race]
    assert_equal 'Humans', @dragon.basic_info[:favorite_food]
  end

  def test_delegation
    assert_equal 1989, @human.birthday_info[:year]
    assert_equal 8, @human.birthday_info[:month]
    assert_equal 30, @human.birthday_info[:day]
  end

  def test_delegation_after_modifying_attribute
    @human.birthday = Date.new(2016, 1, 1)

    assert_equal 2016, @human.birthday_info[:year]
    assert_equal 1, @human.birthday_info[:month]
    assert_equal 1, @human.birthday_info[:day]
  end

  def test_delegation_does_not_define_method_on_the_object
    refute_respond_to @human, :year
    refute_respond_to @human, :month
    refute_respond_to @human, :day
  end

  def test_delegation_uses_the_decorator_singleton_class
    assert_respond_to @dragon.hash_container.context, :hour
    assert_respond_to @dragon.hash_container.context, :minute
    assert_respond_to @dragon.hash_container.context, :second

    refute_respond_to @human.hash_container.context, :hour
    refute_respond_to @human.hash_container.context, :minute
    refute_respond_to @human.hash_container.context, :second
  end

  def test_delegation_doesnt_raise_when_delegated_object_is_null
    assert_empty @animal.age_property
  end

  def test_delegation_with_suffixed_accessor
    assert_equal({ 'name' => 'Edouard', 'age' => '27', 'sexe' => 'Male' }, @animal.owners_properties)
  end

  def test_key_prefix
    assert @human.favorite_info.key?(:favorite_food)
    assert @human.favorite_info.key?(:favorite_color)
    assert @human.favorite_info.key?(:favorite_number)
  end

  def test_key_suffix
    assert @human.clothes_size.key?(:t_shirt_size)
    assert @human.clothes_size.key?(:jean_size)
    assert @human.clothes_size.key?(:shoe_size)
  end

  def test_accessor_prefix
    assert_equal 'Chicken',  @human.prefered_info[:meal]
    assert_equal 'Monopoly', @human.prefered_info[:game]
    assert_equal 'Stargate', @human.prefered_info[:tv_show]
  end

  def test_accessor_suffix
    assert_equal '70kg', @human.attribute_info[:weight]
    assert_equal '185cm', @human.attribute_info[:size]
    assert_equal 'Male', @human.attribute_info[:sexe]
  end

  def test_key_prefix_and_accessor_suffix
    assert_equal({ 'prefered_food' => 'chicken', 'prefered_toy' => 'ball' }, @animal.favorite_properties)
  end

  def test_from_option
    assert_equal 'Hammer', @warrior.combat_info[:weapon]
    assert_equal 44, @warrior.combat_info[:defense]
    assert_equal 91, @warrior.combat_info[:attack]
  end

  def test_from_option_calls_another_method_defined_by_hash_builder
    expected = HashWithIndifferentAccess.new(
      personal_info: {
        health: 100,
        name: 'John Cena',
        gender: 'M',
        speed: 'Very fast'
      }
    )
    assert_equal expected, @warrior.personal_info
  end

  def test_nest_under_option
    assert_equal 'Troll', @warrior.attributes[:attribute][:race]
  end

  def test_deep_nest_under
    expected = HashWithIndifferentAccess.new(
      'history': {
        'background': { 
          'personal_info': { 
            'family': { 
              'father': {
                'father_last_name': 'Kirikou'
              }
            }
          }
        }
      }
    )
    assert_equal expected, @warrior.father_info.to_hash
  end

  def test_condition_on_returned_value_is_false
    assert_empty @dragon.attributes
  end

  def test_condition_on_returned_value_is_true
    assert_equal({ 'armor' => 'Very solid' }, @dragon.armor_stats)
  end

  def test_condition_on_class_is_false
    assert_empty @dragon.make_children
  end

  def test_condition_on_class_is_true
    assert_equal({ 'color' => 'Blue' }, @dragon.color_stats)
  end

  def test_condition_gets_called_only_on_defined_methods
    @dragon.color = ''

    assert @dragon.color_stats_without_condition.key?(:color)
  end

  def test_condition_with_nesting_hash
    @animal.type = ''
    @animal.race = ''

    assert_equal({'properties' => { 'basic' => {} } }, @animal.basic_properties)
  end

  def test_hash_builder_with_all_options
    expected = {
      'type' => 'dog',
      'race' => 'Mixed',
      'advanced' => { 'age' => 19, 'color' => 'black' },
      'owners' => {
        'name' => 'Edouard', 'age' => '27', 'sexe' => 'Male'
      },
      'prefered_food' => 'chicken', 
      'prefered_toy' => 'ball'
    }
    assert_equal expected, @animal.full_properties
  end
end
