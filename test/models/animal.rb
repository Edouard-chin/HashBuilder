Animal = Struct.new(:name, :type, :race, :age, :color, :food_attribute, :toy_attribute, :date_of_birth) do
  include HashBuilder

  hash_builder :type, :race, if: :present?, method_name: :basic_properties, nest_under: [:properties, :basic]
  hash_builder :day, :month, :year, delegate_to: :date_of_birth, method_name: :age_property, if: -> { date_of_birth.present? }
  hash_builder :name, :age, :sexe, accessor_suffix: :_attribute, delegate_to: :owners, method_name: :owners_properties
  
  with_options method_name: :advanced_properties do
    hash_builder :type, :race
    hash_builder :age, :color, nest_under: :advanced
  end

  with_options method_name: :full_properties do
    hash_builder :type, :race
    hash_builder :age, :color, nest_under: :advanced, if: :present?
    hash_builder :owners, from: :owners_properties
    hash_builder :food, :toy, key_prefix: :prefered_, accessor_suffix: :_attribute
  end

  hash_builder :food, :toy, key_prefix: :prefered_, accessor_suffix: :_attribute, method_name: :favorite_properties

  def owners
    OpenStruct.new(name_attribute: 'Edouard', age_attribute: '27', sexe_attribute: 'Male')
  end
end