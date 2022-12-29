STDOUT.sync = true # DO NOT REMOVE

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
     puts x
     tile = {
       scrap_amount: scrap_amount,
       scrap?: scrap_amount > 0,
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
            tile[:reachable] = true
         elsif tile[:recycler] == 1
             my_recyclers.append(tile)
         end
     elsif tile[:owner] == OPP
         opp_tiles.append(tile)
         if tile[:units] > 0
             opp_units.append(tile)
             tile[:reachable] = true
         elsif tile[:recycler] == 1
             opp_recyclers.append(tile)
         end
     else
         neutral_tiles.append(tile)
         tile[:scrap?] ? tile[:reachable] = true : false
     end
    }
    # PARSING DONE
  }

  actions = []
  my_robots = my_units.map { |t| t[:units] }.sum
  opp_robots = opp_units.map { |t| t[:units] }.sum
  role = 0
  builds = 0
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
    opp_near = neighbor(tile, opp_tiles)
    build_here = scrap_around && tile[:in_range_of_recycler]
    my_empty_tiles = my_tiles.select { |t| t[:units] == 0 }
    empty_count = my_empty_tiles.count
    if tile[:can_spawn]
      amount = 0
      kill_opp = 0
      if opp_near.any?
        avail = matter_for_units
        opp_near.each do |opp|
          while opp[:units] >= tile[:units] - 1 && avail > 0
            kill_opp += 1
            avail -= 1
          end
        end
      end

      if matter_for_units > 1 && ((kill_opp > 0 || role % 7 == 6 || my_units.count <= 4))
        if kill_opp > 0
          amount = kill_opp
        elsif no_units && opp_not_far(opp_near, [tile])
          amount = 1
        elsif builds > 0 || my_robots < opp_robots
          matter_for_units == 1 ? amount = 1 : false
        end
      end

      if amount > 0
          actions<<"SPAWN #{amount} #{tile[:x]} #{tile[:y]}"
          matter_for_units -= amount
          spawned = true
      end
    end

    if tile[:can_build] && !spawned && build_here
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
    set_target(my_tiles, width, height)
    target = { x: tile[:tx], y: tile[:ty] }
    if units && target && !spawned && !tile[:built]
      neighbors = neighbor(tile, my_tiles)
      amount = 1 #[tile[:units], 2].min
      if amount > 0 && target
        if [x, y] == [tile[:tx], tile[:ty]]
          empty = neighbors.select { |t| t[:units] == 0 }.shuffle
          neighbor = neighbors.select { |t| t[:reachable] }.shuffle
          any_empty = empty.any?
          any_neighbor = neighbor.any?
          if any_empty
            target[:x], target[:y] = empty.first[:x], empty.first[:y]
          elsif any_neighbor
            target[:x], target[:y] = neighbor.first[:x], neighbor.first[:y]
          end
        end
        if tile_near_opp && role_glob % 4 == 0 && (role % 5 in [2, 3]) && tile[:x] in [1, 2]
          if target[:x] != x + [1, -1].shuffle.first
            target[:x] = x + [1, -1].shuffle.first
          end
          target[:y] = x + [1, -1].shuffle.first, y + [1, -1].shuffle.first
        end
        actions<<"MOVE #{amount} #{tile[:x]} #{tile[:y]} #{target[:x]} #{target[:y]}"
      end
    end
    role += 1
  }

  # To debug: STDERR.puts "Debug messages..."
  STDERR.puts "1337 Benguerir"
  puts actions.size > 0 ? actions*";" : "WAIT"
}
