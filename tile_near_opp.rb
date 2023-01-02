def tile_near_opp(neighbors)
  neighbors.any? { |neighbor| neighbor[:owner] == OPP }
end
