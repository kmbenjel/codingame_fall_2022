STDOUT.sync = true # DO NOT REMOVE
$tiles = Array.new
# Find the farthest point in the field
def farthest(w, h, x, y)
  far_x = x > w/2 ? 0 : w
  far_y = y > h/2 ? 0 : h
  { x: far_x, y: far_y }
end

# Function if_scrap that ensures that coordinates x and y are >= 1, and scrap_amount in the current tile is is >= 1.

def if_scrap(x, y)
  x >= 1 && y >= 1 && $tiles.select { |tile| tile[:x] == x && tile[:y] == y && tile[:scrap_amount] >= 1 } != []
end

# Function if_scrap_around checks if_scrap for the current tile and the four neighboring tiles

def if_scrap_around(x, y)
  if_scrap(x, y) && if_scrap(x - 1, y) && if_scrap(x + 1, y) && if_scrap(x, y - 1) && if_scrap(x, y + 1)
end

# Function that deletes a tile
def delete_tile(x, y, tiles)
  tiles.delete_if { |t| t[:x] == x && t[:y] == y }
end

ME = 1
OPP = 0
NONE = -1

width, height = gets.split.map &:to_i
rolespawn = 0
# game loop
loop {
  rolespawn += 1
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
            tile[:x] == 0 ? (tile[:tx] = 0; tile[:ty] = height - 1) : false
            tile[:y] == height - 1 ? (tile[:tx] = height - 1; tile[:ty] = width - 1) : false
            tile[:x] == width - 1 ? (tile[:tx] = width - 1; tile[:ty] = 0) : false
            tile[:y] == 0 ? (tile[:tx] = 0; tile[:ty] = 0) : false
            my_units.append(tile)
         elsif tile[:recycler]
             my_recyclers.append(tile)
         end
     elsif tile[:owner] == OPP
         opp_tiles.append(tile)
         if tile[:units] > 0
             opp_units.append(tile)
         elsif tile[:recycler]
             opp_recyclers.append(tile)
         end
     else
         neutral_tiles.append(tile)
     end
    }
  }

  actions = []

  my_tiles.each { |tile|
    role += 1
    if tile[:can_spawn]
      if !tile[:units] && my_matter >= 10
        amount = 1
      else
        amount = 0
      end

      if amount > 0
          actions<<"SPAWN #{amount} #{tile[:x]} #{tile[:y]}"
          my_matter -= 10
      end
    end
    if tile[:can_build]
        if if_scrap_around(tile[:x], tile[:y])
          should_build = true
        else
          should_build = false
        end
        if should_build
            actions<<"BUILD #{tile[:x]} #{tile[:y]}"
            delete_tile(tile[:x], tile[:y], my_units)
        end
    end
  }
  my_units.each { |tile|
    # TODO: pick a destination tile
    target = { x: tile[:tx], y: tile[:ty] }
    units = tile[:units]
    if target
      amount = units
      if amount > 0
        actions<<"MOVE #{amount} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
      end
    end
  }
  # To debug: STDERR.puts "Debug messages..."
  puts actions.size > 0 ? actions*";" : "WAIT"
}
