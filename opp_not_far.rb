def opp_not_far(opp_tiles, my_tiles)
  close_tiles = []
  opp_tiles.each do |opp_tile|
    my_tiles.each do |my_tile|
      if (my_tile[:x] - opp_tile[:x]).abs + (my_tile[:y] - opp_tile[:y]).abs <= 2
        close_tiles << my_tile
      end
    end
  end
  return close_tiles
end
