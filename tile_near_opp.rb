def tile_near_opp(neighbors)
  neighbors.any? { |neighbor| neighbor[:owner] == OPP }
end

def separate_cols(tiles, width)
  columns = []
  x_values = (0...width).to_a
  x_values.each do |x_value|
    column_tiles = tiles.select { |tile| tile[:x] == x_value }
    columns[x_value] = column_tiles
  end
  columns
end
