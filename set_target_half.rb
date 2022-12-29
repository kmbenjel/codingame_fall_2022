# Set targets for all my units
def set_target(my_units, width, height)
  # if opp_is_close.empty?
  #   my_units.each do |my_unit|
  #     min_dist = nil
  #     opp_unit = nil
  #     opp_units.each do |opp_unit_pos|
  #       distance = Math.sqrt((my_unit[:x] - opp_unit_pos[:x])**2 + (my_unit[:y] - opp_unit_pos[:y])**2)
  #       if min_dist.nil? || distance < min_dist
  #         min_dist = distance
  #         opp_unit = opp_unit_pos
  #       end
  #     end
  #     my_unit[:tx], my_unit[:ty] = opp_unit[:x], opp_unit[:y]
  #   end
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
