# Collect neighbor tiles of a tile
def neighbor(tile, tiles)
  neighbors = []
  x, y = tile[:x], tile[:y]
  tiles.each do |t|
    if (x == t[:x] && (y - t[:y] == 1 || t[:y] - y == 1)) || (y == t[:y] && (x - t[:x] == 1 || t[:x] - x == 1))
      neighbors << t
    end
  end
  neighbors
end



def neighbors(tiles, my_tile)
  result = []
  tiles.each do |tile|
    if tile[:x] == my_tile[:x] && (tile[:y] == my_tile[:y] + 1 || tile[:y] == my_tile[:y] - 1)
      result << tile
    elsif tile[:y] == my_tile[:y] && (tile[:x] == my_tile[:x] + 1 || tile[:x] == my_tile[:x] - 1)
      result << tile
    end
  end
  result
end

