def farthest(tile, width, height)
    farthest_tile = {
      x: 0,
      y: 0
    }
    max_distance = 0
    0.upto(height - 1) do |y|
      0.upto(width - 1) do |x|
        distance = Math.sqrt((tile[:x] - x)**2 + (tile[:y] - y)**2)
        if distance > max_distance
          max_distance = distance
          farthest_tile[:x] = x
          farthest_tile[:y] = y
        end
      end
    end
    farthest_tile
end
