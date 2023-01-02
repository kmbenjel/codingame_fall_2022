STDOUT.sync = true # DO NOT REMOVE

ME = 1
OPP = 0
NONE = -1
init_x = 0
first_initial_unit = nil
separate_cols = nil
$back_for_build = nil

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

def neighbors(tiles, my_tile)
  result = []
  tiles.each do |tile|
    if tile[:x] == my_tile[:x] && (tile[:y] == my_tile[:y] + 1 || tile[:y] == my_tile[:y] - 1)
      result << tile
    elsif tile[:y] == my_tile[:y] && (tile[:x] == my_tile[:x] + 1 || tile[:x] == my_tile[:x] - 1)
      result << tile
    end
  end
  result
end

def tile_near_opp(neighbors)
  neighbors.any? { |neighbor| neighbor[:owner] == OPP }
end

def separate_cols(tiles, width)
  columns = []
  x_values = (0...width).to_a
  x_values.each do |x_value|
    column_tiles = tiles.select { |tile| tile[:x] == x_value }
    columns[x_value] = column_tiles
  end
  columns
end

def first_initial_unit(tiles)
  initial_unit_x = nil
  initial_unit_y = nil
  tiles.each do |tile|
    if tile[:units] > 0
      if initial_unit_x.nil? || tile[:x] < initial_unit_x
        initial_unit_x = tile[:x]
        initial_unit_y = tile[:y]
      elsif tile[:x] == initial_unit_x && tile[:y] > initial_unit_y
        initial_unit_y = tile[:y]
      end
    end
  end

  tiles.find { |t| t[:x] == initial_unit_x && t[:y] == initial_unit_y }
end

width, height = gets.split.map { |i| i.to_i }
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

  my_matter, opp_matter = gets.split.map { |i| i.to_i }
  height.times { |y|
    width.times { |x|
     # owner: 1 = me, 0 = foe, -1 = neutral
     scrap_amount, owner, units, recycler, can_build, can_spawn, in_range_of_recycler = gets.split.map { |i| i.to_i }

     tile = {
       scrap_amount: scrap_amount,
       owner: owner,
       units: units,
       recycler: recycler==1,
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

  if role_glob == 0
    first_initial_unit = first_initial_unit(tiles)
    init_x = first_initial_unit[:x]
    separate_cols = separate_cols(tiles, width)
    $back_for_build = separate_cols[init_x]
  end

  actions = []
  role= -1

  ###    build and spawn   ###

  my_tiles.each { |tile|
  x = tile[:x]
  y = tile[:y]
  spawned, built = true, true
  units = tile[:units] > 0
  neighbors = neighbors(tiles, tile)
  tile_near_opp = tile_near_opp(neighbors)
  role += 1

  ###   spawn   ###

  if tile[:can_spawn] && ((!units && role % 7 in [1, 5, 6]) || tile_near_opp) && role_glob % 9 != 4
    if my_matter / 10 > 0
      amount = 1
    else
      amount = 0
    end
    if amount > 0
      actions<<"SPAWN #{amount} #{x} #{y}"
      my_matter -= 10
    else
      spawned = nil
    end
  else
    spawned = nil
  end

  ###   build   ###

  if tile[:can_build] && my_matter / 10 > 0 && (tile[:x] == init_x)
    should_build = tile_near_opp && !spawned
    if should_build
      actions<<"BUILD #{x} #{y}"
      my_matter -= 10
    else
      built = nil
    end
  else
    built = nil
  end

  ###   move    ###

  if units && !built
    amount = tile[:units]
    if !tile_near_opp
      if tile[:units] % 2 == 0
        if tiles.any? { |t| t[:owner] == NONE }
          target = nearest_of_owner(tiles, tile, width, height, NONE)
        else
          nearest_of_owner(tiles, tile, width, height, OPP)
        end
        if target && amount > 0
          actions << "MOVE #{amount} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
        end
      else
        opp_empty = opp_tiles.select { |opp| opp[:units] == 0 }
        target = nearest_of_owner(tiles, tile, width, height, OPP)
        if target && amount > 0
          actions << "MOVE #{amount} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
        end
      end
    else
      amount = tile[:units]
      targets = opp_units.select { |opp| opp in neighbors }
      count = targets.count
      opp_role = -1
      while amount > 0 && targets.any?
        opp_role += 1
        if role_glob % 2 == 1
          target = targets[opp_role % count]
        else
          target = nearest_of_owner(tiles, tile, width, height, OPP)
        end
        if target
          actions << "MOVE #{1} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
        end
        amount -= 1
      end
    end
  end
  }
  # To debug: STDERR.puts "Debug messages..."
  actions.size > 0 ? (puts actions*";") : "WAIT"
}
