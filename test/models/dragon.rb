Dragon = Struct.new(:color, :armor, :age, :race, :favorite_food, :name, :gender, :strength) do
  include HashBuilder

  hash_builder :color, :armor, method_name: :skin
  hash_builder :age, :race, :favorite_food, method_name: :basic_info
  hash_builder :name, :gender, :strength, if: :present?, method_name: :attributes
  hash_builder :hour, :minute, :second, method_name: :time_to_fly, delegate_to: :time_to_fly
  hash_builder :copulate, if: -> { adult? }, method_name: :make_children
  hash_builder :armor, if: :present?, method_name: :armor_stats
  hash_builder :color, if: -> { color? }, method_name: :color_stats
  hash_builder :color, method_name: :color_stats_without_condition

  def time_to_fly
    Time.now
  end

  def adult?
    false
  end

  def color?
    true
  end
end
