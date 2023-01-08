# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

n = gets.to_i
p = gets.to_i
c = gets.to_i
r = gets.to_i

# Write an answer using puts
# To debug: STDERR.puts "Debug messages..."
time = 0
(1..n).each { |cat| time += c + ((cat - 1) * 2) + r + p }
puts time
