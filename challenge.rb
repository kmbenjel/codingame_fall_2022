STDOUT.sync = true # DO NOT REMOVE

ME = 1
OPP = 0
NONE = -1

width, height = gets.split.map &:to_i
role_glob = -1
spawn_here = []
build_history = []
dir = nil
last_x = nil

def vanguard(row, dir)
	units = row.select { |t| t[:any_units] && t[:mine] }
	dir == 1 ? units.last : units.first
end

def distribute(tiles, tile, amount, actions)
  x = tile[:x]
  y = tile[:y]
  targets = tiles
  record = []
  if amount <= 0
    return [amount, actions]
  end

  if targets.any?
    part = amount / targets.size
    rem = amount % targets.size
    targets.each { |t|
      if part > 0
        actions << "MOVE #{part + rem} #{x} #{y} #{t[:x]} #{t[:y]}"
        amount -= part + rem
        rem > 0 ? rem -= 1 : false
      elsif rem > 0
        actions << "MOVE #{rem} #{x} #{y} #{t[:x]} #{t[:y]}"
        amount -= rem
        rem -= 1
      end
    }
  end
  record << amount
  record << actions
  return record
end

def nearest_ext(tiles, tile, width, height)
  # select all tiles from the same column
  column_tiles = tiles.select { |t| t[:x] == tile[:x] }
  # select the extreme tiles
  extreme_tiles = column_tiles.select do |t|
    t[:y] == 0 || t[:y] == height - 1
  end
  # find the nearest extreme tile
  nearest = extreme_tiles.min_by { |t| (t[:y] - tile[:y]).abs }
  nearest
end

# Check if I have scrap in the current tile and the neighboring tiles
def scrap_around(tiles, tile, scrap)
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
return total_scrap_amount >= scrap
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

def tile_near_owner(neighbors, owner)
  neighbors.any? { |neighbor| neighbor[:owner] == owner}
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

def nearest_of_none_back(tiles, my_tile, width, height, dir, x)
  tiles_of_owner = tiles.select { |t|
    t[:scrap_amount] > 0 && !t[:mine] && (dir == 1 ? t[:x] < x : t[:x] > x)
  }
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

###   GAME LOOP   ####

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

      scrap_amount, owner, units, recycler, can_build, can_spawn, in_range_of_recycler = gets.split.map &:to_i

      tile = {
        scrap_amount: scrap_amount,
        any_scrap: scrap_amount > 0,
        grass: scrap_amount == 0,
        owner: owner,
        mine: owner == 1,
        theirs: owner == 0,
        neutral: owner == -1,
        units: units,
        any_units: units,
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
        if tile[:any_units]
          my_units.append(tile)

        elsif tile[:recycler]
          my_recyclers.append(tile)
        end
      elsif tile[:owner] == OPP
        opp_tiles.append(tile)
        if tile[:any_units]
          opp_units.append(tile)

        elsif tile[:recycler]
          opp_recyclers.append(tile)
        end
      else
        neutral_tiles.append(tile)

      end
    }
    # PARSING DONE
  }

  ###   COLLECT ACTIONS   ###

  actions = []

  # USEFUL VARIABLES

  my_robots_count = my_units.map { |t| t[:units] }.sum
  opp_robots_count = opp_units.map { |t| t[:units] }.sum
  my_empty_tiles = my_tiles.select { |t| t[:units] == 0 }


  # KNOW DIRECTION

  first_initial_unit(tiles)[:x] < width / 2 ? dir = 1 : dir = -1

  role = -1
  builds = 0
  matter_for_units = my_matter / 10

  ###  IN ENDGAME?  ###

	dir == 1 ? last_x = width - 1 : last_x = 0
	rows = []
	(0...height).each { |r| rows << tiles.select { |t| t[:y] == r } }
	in_endgame = rows.all? { |r|
		vanguard = vanguard(r, dir)
		vanguard ? next_tile = r[vanguard[:x] + dir] : next_tile = {}
		r.any? { |t|
			(t[:mine] && t[:units] && t[:x] == last_x) || (t == vanguard && (next_tile[:recycler] || next_tile[:grass]))
		}
	}
	STDERR.puts in_endgame

  ###   ACTIONS LOOP    ###
  my_tiles.each { |tile|

    role += 1

    x = tile[:x]
    y = tile[:y]

    any_units = tile[:any_units]
    any_matter = matter_for_units > 0
    no_units = !tile[:any_units]
    #amount = tile[:units]
    neighbors = neighbors(tiles, tile)
    tile_near_opp = tile_near_owner(neighbors, OPP)
    opp_neighbor_units = neighbors.select { |n| n[:theirs] && n[:any_units] }
    neighbor_not_mine = neighbors.select { |n| !n[:recycler] && !n[:mine] && n[:any_scrap]}
    nearest_of_none = nearest_of_owner(tiles, tile, width, height, NONE)
    nearest_of_opp = nearest_of_owner(tiles, tile, width, height, OPP)
    neighbor_not_mine_no_back = neighbor_not_mine.select { |n| [x, x + dir].include?(n[:x]) }
    nearest_of_none_back = nearest_of_none_back(tiles, tile, width, height, dir, x)
    not_mine = tiles.select { |t| !t[:mine] && t[:any_scrap] }
    # not_mine_in_back = not_mine.select { |t| dir == 1 ? t[:x] < x : t[:x] > x }

    ###   BUILD   ###
    should_build = nil
    if tile[:can_build] && any_matter

      # SHOULD BUILD?
      build_back = [
        role_glob <= 20,
        scrap_around(tiles, tile, 40),
        x < width / 2,
        y < height - 2 && y > 2,
        neighbors.any? { |n| n[:mine] && n[:any_units] },
        neighbors.all? { |n| !n[:recycler]},
        role % 3 == 2
      ]

      build_ahead = [
        neighbors.any? { |n| n[:any_units] && n[:theirs] }
      ]

      build_conditions = build_back.all? || build_ahead.all?
      build_conditions ? should_build = true : false

      # BUILD ACTION
      if should_build
        actions << "BUILD #{x} #{y}"
        matter_for_units -= 1
        tile[:built] = true
      end
    end

    ###   SPAWN    ###

    if tile[:can_spawn] && any_matter
      spawn_here = my_tiles.select {|t| t[:any_units] && neighbors(tiles, t).any? { |n| n[:theirs] && n[:any_units] } }
      amount = matter_for_units
      while amount > 0 && spawn_here.any? do
        sample = spawn_here.sample
        sx, sy = sample[:x], sample[:y]
        actions << "SPAWN 1 #{sx} #{sy}"
        amount -= 1
        spawn_here.delete(sample)
      end

      if amount > 0 && any_units && role_glob % 3 == 1
        actions << "SPAWN #{1} #{x} #{y}"
        amount -= 1
      end
      matter_for_units = amount
    end


    ###   MOVE    ###

    if any_units && !tile[:built]
      if tile_near_opp
        record = distribute(opp_neighbor_units, tile, amount, actions)
        amount, actions = record
        amount = distribute(neighbor_not_mine, tile, amount, actions)
        amount, actions = record
      elsif in_endgame
        record = distribute([nearest_of_none_back], tile, amount, actions)
        amount, actions = record
      else
        record = distribute(neighbor_not_mine_no_back + [nearest_of_opp], tile, amount, actions)
        amount, actions = record
        # record = distribute([nearest_of_opp], tile, amount, actions)
        # amount, actions = record
      end
    end
  }
  # To debug: STDERR.puts "Debug messages..."
  STDERR.puts "KHALID, 42-intra: kbenjell"
  puts actions.size > 0 ? actions*";" : "WAIT"
}

# t = nearest_ext(tiles, tile, width, height)
# if amount > 0
#   actions << "MOVE 1 #{x} #{y} #{t[:x]} #{t[:y]}"
#   amount -= 1
# end

