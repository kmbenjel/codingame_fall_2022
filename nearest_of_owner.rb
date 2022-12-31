def nearest_of_owner(tiles, my_tile, width, height, owner)
  tiles_of_owner = tiles.select { |tile| tile[:scrap_amount] > 0 && tile[:owner] == owner }
  return nil if tiles_of_owner.empty?

  min_dist = nil
  result = nil

  tiles_of_owner.each do |tile|
    dist = (my_tile[:x] - tile[:x]).abs + (my_tile[:y] - tile[:y]).abs

    if min_dist.nil? || dist < min_dist
      min_dist = dist
      result = { x: tile[:x], y: tile[:y] }
    end
  end

  result
end
