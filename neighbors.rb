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

