STDOUT.sync = true # DO NOT REMOVE
$tiles = Array.new
# Find the farthest point in the field
def farthest(w, h, x, y)
  far_x = x > w/2 ? 0 : w
  far_y = y > h/2 ? 0 : h
  { x: far_x, y: far_y }
end

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

# Check if I have scrap in the current tile and the neighboring tiles
def scrap_around(tile)
  neighbors = [
    { x: tile[:x] - 1, y: tile[:y] },
    { x: tile[:x] + 1, y: tile[:y] },
    { x: tile[:x], y: tile[:y] - 1 },
    { x: tile[:x], y: tile[:y] + 1 },
  ]

  neighbors.all? do |neighbor|
    neighbor[:scrap_amount] >= 1
  end
end

# Check if x is in the second column
def in_second_column(height, width, x)
  x == 1 || x == width - 2 ? true : false
end

ME = 1
OPP = 0
NONE = -1

width, height = gets.split.map &:to_i
role = 0

# game loop
loop {
  role += 1
  tiles = []
  my_units = []
  opp_units = []
  my_recyclers = []
  opp_recyclers = []
  opp_tiles = []
  my_tiles = []
  neutral_tiles = []

  my_matter, opp_matter = gets.split.map &:to_i
  height.times { |y|
    width.times { |x|
     # owner: 1 = me, 0 = foe, -1 = neutral
     scrap_amount, owner, units, recycler, can_build, can_spawn, in_range_of_recycler = gets.split.map &:to_i
     tile = {
       scrap_amount: scrap_amount,
       owner: owner,
       units: units,
       recycler: recycler,
       can_build: can_build==1,
       can_spawn: can_spawn==1,
       in_range_of_recycler: in_range_of_recycler==1,
       x: x,
       y: y
     }

     tiles.append(tile)
     $tiles = tiles
     if tile[:owner] == ME
         my_tiles.append(tile)
         if tile[:units] > 0
            far = farthest(width, height, tile[:x], tile[:y])
            tile[:tx] = far[:x]
            tile[:ty] = far[:y]
            tile[:x] == 0 && tile[:y] != height - 1 ? (tile[:tx] = 0; tile[:ty] = height - 1) : false
            tile[:y] == height - 1 && tile[:x] != width - 1 ? (tile[:tx] = width - 1; tile[:ty] = height - 1) : false
            tile[:x] == width - 1 && tile[:y] != 0 ? (tile[:tx] = width - 1; tile[:ty] = 0) : false
            tile[:y] == 0 && tile[:x] != 0 ? (tile[:tx] = 0; tile[:ty] = 0) : false
            my_units.append(tile)
         elsif tile[:recycler] == 1
             my_recyclers.append(tile)
         end
     elsif tile[:owner] == OPP
         opp_tiles.append(tile)
         if tile[:units] > 0
             opp_units.append(tile)
         elsif tile[:recycler] == 1
             opp_recyclers.append(tile)
         end
     else
         neutral_tiles.append(tile)
     end
    }
  }
  built = false
  spawned = false
  actions = []
  first_opp = opp_tiles.first
  opp_is_close = opp_is_close(opp_tiles, my_tiles)
  my_tiles.each { |tile|
    x = tile[:x]
    y = tile[:y]
    if tile[:can_spawn] && (tile[:units] == 0 || my_tiles.count < 4 || [x, y] == [width / 2, height / 2])
      if my_matter >= 10 && !tile[:in_range_of_recycler] && !opp_is_close.include?(tile)
        if opp_is_close.any? && my_matter > opp_is_close.count * 10
          amount = (my_matter / 10) - (opp_is_close.count * 10)
        else
          amount = my_matter / 10
        end
      else
        amount = 0
      end
      if amount > 0
          actions<<"SPAWN #{amount} #{tile[:x]} #{tile[:y]}"
          my_matter -= amount
          spawned = true
      end
    end
    x_in_second = in_second_column(height, width, x)
    build_here = my_tiles.select { |t| opp_is_close.include?(t) || (!opp_is_close.any? && x_in_second && scrap_around(t)) }
    if tile[:can_build] && tile in build_here
        if my_matter >= 10
          should_build = true
        else
          should_build = false
        end
        if should_build
            actions<<"BUILD #{tile[:x]} #{tile[:y]}"
            built = true
            my_matter -= 10
        end
    end
  }

  r = 0
  my_units.each { |tile|
    # TODO: pick a destination tile
    r += 1
    x = tile[:x]
    y = tile[:y]
    if (role % 6 == 4) && x != 0 && y != 0
      [tile[:tx], tile[:ty]] != [x, 0] ? (tile[:tx] = x; tile[:ty] = 0) : false
    elsif (role % 6 == 1) && x != 0 && y != 0
      [tile[:tx], tile[:ty]] != [x, height - 1] ? (tile[:tx] = x; tile[:ty] = height - 1) : false
    end
    if tile[:in_range_of_recycler]
      tile[:tx] = farthest(width, height, first_opp[:x], first_opp[:y])[:x]
      tile[:ty] = farthest(width, height, first_opp[:x], first_opp[:y])[:y]
    end
    target = { x: tile[:tx], y: tile[:ty] }
    units = tile[:units]
    if target && !built && !spawned
      units / 2 > 0 ? amount = units / 2 : amount = units
      if amount > 0
        actions<<"MOVE #{amount} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
      end
    end
  }
  # To debug: STDERR.puts "Debug messages..."
  puts actions.size > 0 ? actions*";" : "WAIT"
}
