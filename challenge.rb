# frozen_string_literal: false

STDOUT.sync = true # DO NOT REMOVE
require 'benchmark'
ME = 1
OPP = 0
NONE = -1

@first_initial_unit = 0
@dir = 0
width, height = gets.split.map(&:to_i)
role_glob = -1
last_x = nil

def vanguard(row, dir)
  units = row.select { |t| t[:mine] && !t[:recycler] }
  dir == 1 ? units.last : units.first
end

def distribute(tiles, tile, amount, actions)
  x = tile[:x]
  y = tile[:y]
  targets = tiles
  record = []
  return [amount, actions] if amount <= 0

  if targets.any?
    part = amount / targets.size
    rem = amount % targets.size
    targets.each do |t|
      if part.positive?
        actions << "MOVE #{part + rem} #{x} #{y} #{t[:x]} #{t[:y]}"
        amount -= part + rem
        rem = 0
      elsif rem.positive?
        actions << "MOVE #{rem} #{x} #{y} #{t[:x]} #{t[:y]}"
        amount -= rem
        rem = 0
      end
    end
  end
  record << amount
  record << actions
  record
end

# def nearest_ext(tiles, tile, width, height)
#   # select all tiles from the same column
#   column_tiles = tiles.select { |t| t[:x] == tile[:x] }
#   # select the extreme tiles
#   extreme_tiles = column_tiles.select do |t|
#     t[:y] == 0 || t[:y] == height - 1
#   end
#   # find the nearest extreme tile
#   nearest = extreme_tiles.min_by { |t| (t[:y] - tile[:y]).abs }
#   nearest
# end

# Check if I have scrap in the current tile and the neighboring tiles
# def scrap_around(tiles, tile, scrap)
#   total_scrap_amount = 0
#   tiles.each do |t|
#     if ((t[:x] == tile[:x] && t[:y] == tile[:y] + 1) ||
#       (t[:x] == tile[:x] && t[:y] == tile[:y] - 1) ||
#       (t[:y] == tile[:y] && t[:x] == tile[:x] + 1) ||
#       (t[:y] == tile[:y] && t[:x] == tile[:x] - 1) ||
#     (t[:x] == tile[:x] && t[:y] == tile[:y]))
#     total_scrap_amount += t[:scrap_amount]
#     end
# end
# return total_scrap_amount >= scrap
# end

def first_initial_unit(tiles)
  tiles.select { |tile| tile[:any_units] == true && tile[:mine] == true }.sample
end

def tile_near_owner(neighbors, owner)
  neighbors.any? { |neighbor| neighbor[:owner] == owner && !neighbor[:recycler] }
end

def nearest_of_owner(tiles, my_tile, _width, _height, owner)
  tiles_of_owner = tiles.select { |tile| tile[:scrap_amount].positive? && tile[:owner] == owner }
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

# def nearest_of_none_back(tiles, my_tile, width, height, dir, x)
#   tiles_of_owner = tiles.select { |t|
#     t[:scrap_amount] > 0 && !t[:mine] && (dir == 1 ? t[:x] < x : t[:x] > x)
#   }
#   return nil if tiles_of_owner.empty?

#   min_dist = nil
#   result = nil

#   tiles_of_owner.each do |tile|
#     dist = (my_tile[:x] - tile[:x]).abs + (my_tile[:y] - tile[:y]).abs

#     if min_dist.nil? || dist < min_dist
#       min_dist = dist
#       result = { x: tile[:x], y: tile[:y] }
#     end
#   end

#   result
# end

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

loop do
  role_glob += 1
  tiles = []
  my_units = []
  opp_units = []
  my_recyclers = []
  opp_recyclers = []
  opp_tiles = []
  my_tiles = []
  neutral_tiles = []

  my_matter, _opp_matter = gets.split.map(&:to_i)
  height.times do |y|
    width.times do |x|
      scrap_amount, owner, units, recycler, can_build, can_spawn, in_range_of_recycler = gets.split.map(&:to_i)
      tile = {
        scrap_amount: scrap_amount,
        any_scrap: scrap_amount > 0,
        grass: scrap_amount == 0,
        owner: owner,
        mine: owner == 1,
        theirs: owner == 0,
        neutral: owner == -1,
        units: units,
        any_units: units > 0,
        recycler: recycler == 1,
        can_build: can_build == 1,
        can_spawn: can_spawn == 1,
        in_range_of_recycler: in_range_of_recycler == 1,
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
    end
    # PARSING DONE
  end

  time = Benchmark.realtime do
    ###   COLLECT ACTIONS   ###

    actions = []

    # USEFUL VARIABLES

    # KNOW DIRECTION
    if role_glob == 0
      first_initial_unit = first_initial_unit(tiles)[:x]
      @dir = first_initial_unit < width / 2 ? 1 : -1
    end

    role = -1
    builds = 0
    matter_for_units = my_matter / 10

    ###  IN ENDGAME?  ###
    last_x = @dir == 1 ? width - 1 : 0
    rows = []
    (0...height).each do |r|
      rows << tiles.select { |t| t[:y] == r }
    end
    in_endgame = rows.all? do |r|
      vanguard = vanguard(r, @dir)
      if vanguard
        nx = vanguard[:x] + @dir
        ny = vanguard[:y]
        next_tile = tiles.find { |t| t[:x] == nx && t[:y] == ny }
        next_tile && (next_tile[:recycler] || next_tile[:grass])
      else
        true
      end
      # vanguard ? next_tile = r[vanguard[:x] + @dir] : next_tile = {}
      # r.any? { |t|
      #     (t[:mine] && t[:units] && t[:x] == last_x) || (t == vanguard && !(next_tile[:theirs] && next_tile[:units]))
      # }
    end

    vanguards = []
    rows.each { |r| vanguards << vanguard(r, @dir) if vanguard(r, @dir) }

    ###   ACTIONS LOOP    ###
    my_tiles.each do |tile|
      role += 1

      x = tile[:x]
      y = tile[:y]

      any_units = tile[:any_units]
      any_matter = matter_for_units > 0
      no_units = !tile[:any_units]
      neighbors = neighbors(tiles, tile)
      neighbors_avail = neighbors.select { |n| n[:any_scrap] && !n[:recycler] }
      tile_near_opp = tile_near_owner(neighbors, OPP)
      opp_neighbor_units = neighbors.select { |n| n[:theirs] && n[:any_units] }
      neighbor_not_mine = neighbors.select { |n| !n[:recycler] && !n[:mine] && n[:any_scrap] }
      nearest_of_none = nearest_of_owner(tiles, tile, width, height, NONE)
      nearest_of_opp = nearest_of_owner(tiles, tile, width, height, OPP)
      nearest_not_mine = [nearest_of_none, nearest_of_opp].filter { |t| t }
      neighbor_not_mine_no_back = neighbor_not_mine.select do |n|
        [x, x + @dir].include?(n[:x]) && !n[:in_range_of_recycler]
      end
      no_back = neighbors_avail.select do |n|
        nx = n[:x]
        nx == x + @dir || nx == x
        !n[:in_range_of_recycler]
      end
      back = neighbors_avail.select do |n|
        nx = n[:x]
        nx == x - @dir || nx == x
      end
      back_neutral = back.select { |n| n[:neutral] }

      ###   BUILD   ###
      should_build = nil
      find_build = my_tiles.find do |t|
        neighbors(tiles, t).any? { |n| n[:theirs] }
      end
      if any_matter && role == 0
        # SHOULD BUILD?
        if role_glob == 0
          b = my_tiles.find { |t| !t[:any_units] && t[:can_build] }
          bx = b[:x]
          by = b[:y]
          actions << "BUILD #{bx} #{by}"
          my_tiles.each { |t| t == b ? t[:built] = 1 : false }
          warn '296'
          matter_for_units -= 1
        elsif role_glob <= width / 2 && role_glob % 3 == 2
          b = my_tiles.select { |t| !t[:any_units] && t[:can_build] }.sample
          bx = b[:x]
          by = b[:y]
          actions << "BUILD #{bx} #{by}"
          my_tiles.each { |t| t == b ? t[:built] = 1 : false }
          matter_for_units -= 1
          warn '304'
        elsif find_build
          b = find_build
          bx = b[:x]
          by = b[:y]
          actions << "BUILD #{bx} #{by}"
          my_tiles.each { |t| t == b ? t[:built] = 1 : false }
          matter_for_units -= 1
          warn '311, find_build'
        end
      end

      ###   SPAWN    ###

      if any_matter && role == 0 && role_glob != 0 && role_glob % 5 != 2
        while matter_for_units > 0
          sample = vanguards.select { |v| v[:any_units] }.sample

          if sample && sample[:can_spawn]
            sx = sample[:x]
            sy = sample[:y]
            actions << "SPAWN 1 #{sx} #{sy}"
            matter_for_units -= 1
            vanguards.delete(sample)
            warn '340, SPAWNED'
          else
            break
          end
        end
      end

      ###   MOVE    ###

      next unless any_units && !tile[:built] && !tile[:recycler]

      amount = tile[:units]
      warn '357, About to move'
      if tile_near_opp
        record = distribute([nearest_of_opp], tile, amount, actions)
        amount, actions = record
        record = distribute(opp_neighbor_units, tile, amount, actions)
        amount, actions = record
        amount = distribute(neighbor_not_mine, tile, amount, actions)
        amount, actions = record
      elsif in_endgame
        record = distribute(back_neutral, tile, amount, actions)
        amount, actions = record
        record = distribute(back, tile, amount, actions)
        amount, actions = record
      else

        # record = distribute([nearest_of_opp], tile, amount, actions)
        # amount, actions = record
        record = distribute(neighbor_not_mine_no_back, tile, amount, actions)
        amount, actions = record
        # record = distribute(no_back, tile, amount, actions)
        # amount, actions = record
        record = distribute(nearest_not_mine, tile, amount, actions)
        amount, actions = record
      end
      warn '381, Just tried to move'
    end
    actions << 'MESSAGE KHALID, 42-intra: kbenjell'
    puts actions.empty? ? 'WAIT' : actions * ';'
  end
  warn "Time elapsed #{time * 1000} milliseconds"
end
