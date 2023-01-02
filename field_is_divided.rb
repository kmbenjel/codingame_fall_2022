
def field_is_divided(tiles)
  # find min and max x and y
  x_max = tiles.max_by { |tile| tile[:x] }[:x]
  x_min = tiles.min_by { |tile| tile[:x] }[:x]
  y_max = tiles.max_by { |tile| tile[:y] }[:y]
  y_min = tiles.min_by { |tile| tile[:y] }[:y]

  # check if the field is divided by grass tiles
  (y_min..y_max).each do |y|
    # flags for know if current row is divided by grass tiles
    left_blocked = false
    right_blocked = false

    (x_min..x_max).each do |x|
      tile = tiles.find { |tile| tile[:x] == x && tile[:y] == y }
      if tile && tile[:grass]
        # if grass tile found, check if it's connected vertically
        if is_connected_vertically(tiles, x, y)
          # if it's connected, set flag for the side of the field it's on
          if x >= x_max/2
            right_blocked = true
          else
            left_blocked = true
          end
        end
      end
    end

    # if both flags are true, the field is divided by grass tiles
    if left_blocked && right_blocked
      return true
    end
  end

  # if no row is divided by grass tiles, return false
  false
end

# helper function to check if grass tile is connected vertically
def is_connected_vertically(tiles, x, y)
  # check if there's a grass tile above or below current tile
  above_tile = tiles.find { |tile| tile[:x] == x && tile[:y] == y - 1 }
  below_tile = tiles.find { |tile| tile[:x] == x && tile[:y] == y + 1 }

  # return true if one of the tiles is grass
  above_tile && above_tile[:grass] || below_tile && below_tile[:grass]
end
