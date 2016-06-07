Warrior = Struct.new(:health, :name, :gender, :speed, :race, :father_last_name) do
  include HashBuilder

  hash_builder :health, :name, :gender, :speed, method_name: :basic_info
  hash_builder :stats, from: :statistics, method_name: :combat_info

  hash_builder :personal_info, from: :basic_info, method_name: :personal_info

  hash_builder :race, nest_under: :attribute, method_name: :attributes
  hash_builder :father_last_name,
    nest_under: [:history, :background, :personal_info, :family, :father], method_name: :father_info

  def combat_info
    { weapon: 'Hammer', defense: 44, attack: 91 }
  end
end