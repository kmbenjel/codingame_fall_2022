
STDOUT.sync = true # DO NOT REMOVE

$opp_units_initial = []

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

# Check if x is in the second column
def in_second_column(height, width, x)
  x == 1 || x == width - 2 ? true : false
end

# Set targets for all my units
# def set_target(my_units, opp_units, opp_is_close, width, height)
#   if opp_is_close.empty?
#     my_units.each { |unit| unit[:tx], unit[:ty] = tx, ty }
#   else
#     half = my_units.length / 2
#     top_half = my_units[0..half - 1]
#     bottom_half = my_units[half..-1]
#     if my_units.first[:x] > width/2
#       top_half.each { |unit| unit[:tx], unit[:ty] = 2, 0 }
#       bottom_half.each { |unit| unit[:tx], unit[:ty] = 2, height - 1 }
#     else
#       top_half.each { |unit| unit[:tx], unit[:ty] = width - 3, 0 }
#       bottom_half.each { |unit| unit[:tx], unit[:ty] = width - 3, height - 1 }
#     end
#   end
# end

def set_target(my_units, opp_units, opp_is_close, width, height)
  if opp_is_close.empty?
    my_units.each do |my_unit|
      min_dist = nil
      opp_unit = nil
      opp_units.each do |opp_unit_pos|
        distance = Math.sqrt((my_unit[:x] - opp_unit_pos[:x])**2 + (my_unit[:y] - opp_unit_pos[:y])**2)
        if min_dist.nil? || distance < min_dist
          min_dist = distance
          opp_unit = opp_unit_pos
        end
      end
      my_unit[:tx], my_unit[:ty] = opp_unit[:x], opp_unit[:y]
    end
  else
    half = my_units.length / 2
    top_half = my_units[0..half - 1]
    bottom_half = my_units[half..-1]
    if my_units.first[:x] > width/2
      top_half.each { |unit| unit[:tx], unit[:ty] = 2, 0 }
      bottom_half.each { |unit| unit[:tx], unit[:ty] = 2, height - 1 }
    else
      top_half.each { |unit| unit[:tx], unit[:ty] = width - 3, 0 }
      bottom_half.each { |unit| unit[:tx], unit[:ty] = width - 3, height - 1 }
    end
  end
end

ME = 1
OPP = 0
NONE = -1

width, height = gets.split.map &:to_i
role_glob = -1

# game loop
loop {
  role_glob += 1
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
     if tile[:owner] == ME
         my_tiles.append(tile)
         if tile[:units] > 0
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
  if role_glob == 0
    $opp_units_initial = opp_units
  end
  actions = []
  my_robots = my_units.map { |t| t[:units] }.sum
  opp_robots = opp_units.map { |t| t[:units] }.sum
  first_opp = opp_tiles.first
  opp_is_close = opp_is_close(opp_tiles, my_tiles)
  opp_not_far = opp_not_far(opp_tiles, my_tiles)
  set_target(my_tiles, $opp_units_initial, opp_not_far, width, height)
  builds = 0
  role = 0
  built = builds > 0
  matter_for_units = my_matter / 10
  my_tiles.each { |tile|
    spawned = false
    x = tile[:x]
    y = tile[:y]
    units = tile[:units] > 0
    no_units = tile[:units] == 0
    tile_near_opp = opp_is_close.any?(tile)
    in_second_column = in_second_column(height, width, x)
    scrap_around = scrap_around(tiles, tile)
    build_here = scrap_around && tile_in_tail
    build_here && tile[:can_build] ? built = true : built = false
    my_empty_tiles = my_tiles.select { |t| t[:units] == 0 }
    empty_count = my_empty_tiles.count
    if tile[:can_spawn]
      amount = 0
      if matter_for_units > 1 && ((role % 5 == 4) || my_units.count <= 4)
        if no_units
          amount = [matter_for_units / my_units.count, 1].min
        elsif built || my_robots < opp_robots
          amount = matter_for_units / my_units.count - 1
        end
      end
      if amount > 0
          actions<<"SPAWN #{amount} #{tile[:x]} #{tile[:y]}"
          matter_for_units -= amount
          spawned = true
      end
    end
    if tile[:can_build] && !spawned && build_here && role_glob % 10 == 1
        if matter_for_units > 0
          should_build = true
        else
          should_build = false
        end
        if should_build
            actions<<"BUILD #{tile[:x]} #{tile[:y]}"
            builds += 1
            tile[:built] = 1
            my_matter -= 10
        end
    end
    target = { x: tile[:tx], y: tile[:ty] }
    if units && target && !spawned && !tile[:built]
      amount = [tile[:units], 2].min
      if amount > 0 && target
        if [x, y] == [tile[:tx], tile[:ty]]
          # Change target when unit is already in the rarget
          target[:x] += 1
        elsif role_glob % 2 == 0 && role % 5 in [2, 3]
          amount= 1
          target[:x], target[:y] = x + [1, -1].shuffle.first, y + [1, -1].shuffle.first
        end
        actions<<"MOVE #{amount} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
      end
    end
    role += 1
  }

  # To debug: STDERR.puts "Debug messages..."
  puts actions.size > 0 ? actions*";" : "WAIT"
}
