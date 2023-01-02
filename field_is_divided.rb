#  ruby function field_is_divided(tiles, dir_vector), that returns true if a car can't move in dir_vector direction, false if a car can move so.
# a car can't move to a tile when it is :grass.
# a car can't move that way if in every row there's a tile that's :grass, and that we could find grass tiles that are connected vertically from top to bottom (two tiles could be connected when they are neigbors diagonally as well as when they are neighbors horizontally or vertically), like in tiles1 below.

# tiles form a rectangular field of tiles and every tile may have cars on it that can move to an adjacent tile.
# every tile has :x and :y.
# you could have for example: tiles1 = [{:x=>0, :y=>0, :grass=>false}, {:x=>1, :y=>0, :grass=>false}, {:x=>2, :y=>0, :grass=>false}, {:x=>3, :y=>0, :grass=>false}, {:x=>4, :y=>0, :grass=>true}, {:x=>5, :y=>0, :grass=>false}, {:x=>6, :y=>0, :grass=>false}, {:x=>0, :y=>1, :grass=>false}, {:x=>1, :y=>1, :grass=>false}, {:x=>2, :y=>1, :grass=>false}, {:x=>3, :y=>1, :grass=>false}, {:x=>4, :y=>1, :grass=>false}, {:x=>5, :y=>1, :grass=>true}, {:x=>6, :y=>1, :grass=>false}, {:x=>0, :y=>2, :grass=>false}, {:x=>1, :y=>2, :grass=>false}, {:x=>2, :y=>2, :grass=>false}, {:x=>3, :y=>2, :grass=>false}, {:x=>4, :y=>2, :grass=>false}, {:x=>5, :y=>2, :grass=>true}, {:x=>6, :y=>2, :grass=>false}, {:x=>0, :y=>3, :grass=>false}, {:x=>1, :y=>3, :grass=>false}, {:x=>2, :y=>3, :grass=>false}, {:x=>3, :y=>3, :grass=>false}, {:x=>4, :y=>3, :grass=>true}, {:x=>5, :y=>3, :grass=>false}, {:x=>6, :y=>3, :grass=>false}, {:x=>0, :y=>4, :grass=>false}, {:x=>1, :y=>4, :grass=>false}, {:x=>2, :y=>4, :grass=>false}, {:x=>3, :y=>4, :grass=>true}, {:x=>4, :y=>4, :grass=>false}, {:x=>5, :y=>4, :grass=>false}, {:x=>6, :y=>4, :grass=>false}]; in this case field_is_divided(tiles1) is true, while for tiles2 = [{:x=>0, :y=>0, :grass=>false}, {:x=>1, :y=>0, :grass=>false}, {:x=>2, :y=>0, :grass=>false}, {:x=>3, :y=>0, :grass=>false}, {:x=>4, :y=>0, :grass=>true}, {:x=>5, :y=>0, :grass=>false}, {:x=>6, :y=>0, :grass=>false}, {:x=>0, :y=>1, :grass=>false}, {:x=>1, :y=>1, :grass=>false}, {:x=>2, :y=>1, :grass=>false}, {:x=>3, :y=>1, :grass=>false}, {:x=>4, :y=>1, :grass=>false}, {:x=>5, :y=>1, :grass=>true}, {:x=>6, :y=>1, :grass=>false}, {:x=>0, :y=>2, :grass=>false}, {:x=>1, :y=>2, :grass=>false}, {:x=>2, :y=>2, :grass=>false}, {:x=>3, :y=>2, :grass=>false}, {:x=>4, :y=>2, :grass=>false}, {:x=>5, :y=>2, :grass=>true}, {:x=>6, :y=>2, :grass=>false}, {:x=>0, :y=>3, :grass=>false}, {:x=>1, :y=>3, :grass=>false}, {:x=>2, :y=>3, :grass=>false}, {:x=>3, :y=>3, :grass=>false}, {:x=>4, :y=>3, :grass=>true}, {:x=>5, :y=>3, :grass=>false}, {:x=>6, :y=>3, :grass=>false}, {:x=>0, :y=>4, :grass=>false}, {:x=>1, :y=>4, :grass=>false}, {:x=>2, :y=>4, :grass=>false}, {:x=>3, :y=>4, :grass=>false}, {:x=>4, :y=>4, :grass=>false}, {:x=>5, :y=>4, :grass=>false}, {:x=>6, :y=>4, :grass=>true}], field_is_divides(tiles2) is false.




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
