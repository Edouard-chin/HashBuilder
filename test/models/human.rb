attributes = %i(
  birthday prefered_meal prefered_game prefered_tv_show weight_attribute size_attribute sexe_attribute
  t_shirt jean shoe food color number
)
Human = Struct.new(*attributes) do
  include HashBuilder

  hash_builder :year, :month, :day, delegate_to: :birthday, method_name: :birthday_info

  hash_builder :food, :color, :number, key_prefix: :favorite_, method_name: :favorite_info
  hash_builder :t_shirt, :jean, :shoe, key_suffix: :_size, method_name: :clothes_size
  hash_builder :meal, :game, :tv_show, accessor_prefix: :prefered_, method_name: :prefered_info
  hash_builder :weight, :size, :sexe, accessor_suffix: :_attribute, method_name: :attribute_info
end