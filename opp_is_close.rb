# Collect my tiles neighboring the opponent tiles
def opp_is_close(opp_tiles, my_tiles)
  close_tiles = []
  opp_tiles.each do |opp_tile|
    my_tiles.each do |my_tile|
      if (my_tile[:x] - opp_tile[:x]).abs + (my_tile[:y] - opp_tile[:y]).abs == 1
        close_tiles << my_tile
      end
    end
  end
  return close_tiles
end
