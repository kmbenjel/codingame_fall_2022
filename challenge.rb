STDOUT.sync = true # DO NOT REMOVE
# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

width, height = gets.split(" ").collect { |x| x.to_i }

# game loop
loop do
  my_matter, opp_matter = gets.split(" ").collect { |x| x.to_i }
  height.times do
    width.times do
      # owner: 1 = me, 0 = foe, -1 = neutral
      scrap_amount, owner, units, recycler, can_build, can_spawn, in_range_of_recycler = gets.split(" ").collect { |x| x.to_i }
    end
  end

  # Write an action using puts
  # To debug: STDERR.puts "Debug messages..."

  puts "WAIT"
end
