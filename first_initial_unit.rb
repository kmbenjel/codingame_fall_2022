def first_initial_unit(tiles)
  initial_unit_x = nil
  initial_unit_y = nil
  tiles.each do |tile|
    if tile[:units] > 0
      if initial_unit_x.nil? || tile[:x] < initial_unit_x
        initial_unit_x = tile[:x]
        initial_unit_y = tile[:y]
      elsif tile[:x] == initial_unit_x && tile[:y] > initial_unit_y
        initial_unit_y = tile[:y]
      end
    end
  end

  tiles.find { |t| t[:x] == initial_unit_x && t[:y] == initial_unit_y }
end
