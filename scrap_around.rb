# Check if I have scrap in the current tile and the neighboring tiles
def scrap_around(tiles, tile)
  total_scrap_amount = 0
  tiles.each do |t|
    if ((t[:x] == tile[:x] && t[:y] == tile[:y] + 1) ||
        (t[:x] == tile[:x] && t[:y] == tile[:y] - 1) ||
        (t[:y] == tile[:y] && t[:x] == tile[:x] + 1) ||
        (t[:y] == tile[:y] && t[:x] == tile[:x] - 1) ||
        (t[:x] == tile[:x] && t[:y] == tile[:y]))
      total_scrap_amount += t[:scrap_amount]
    end
  end
  return total_scrap_amount >= 3
end
