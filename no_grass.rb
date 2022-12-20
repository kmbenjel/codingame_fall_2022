#write a function that gives every tile a
  # Function if_scrap that ensures that coordinates x and y are >= 1, and scrap_amount in the current tile is is >= 1
  def if_scrap(x, y)
    x >= 1 && y >= 1 && $tiles.select { |tile| tile[:x] == x && tile[:y] = y }.first[:scrap_amount] >= 1
  end

  # Function if_scrap_around checks if_scrap for the current tile and the four neighboring tiles
  def if_scrap_around(x, y)
    if_scrap(x, y) || if_scrap(x - 1, y) || if_scrap(x + 1, y) || if_scrap(x, y - 1) || if_scrap(x, y + 1)
  end

  def opp_neighbor(tile)
    neighbors = [
      { x: tile[:x], y: tile[:y] - 1 },
      { x: tile[:x], y: tile[:y] + 1 },
      { x: tile[:x] - 1, y: tile[:y] },
      { x: tile[:x] + 1, y: tile[:y] }
    ]
    neighbors.each do |neighbor|
      return true if $tiles.any? { |t| t[:x] == neighbor[:x] && t[:y] == neighbor[:y] && t[:owner] == OPP }
    end
    return false
  end

  