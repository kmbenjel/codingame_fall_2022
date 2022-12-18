



def farthest_point(w, h, x, y)
  far_x = x > w/2 ? 0 : w
  far_y = y > h/2 ? 0 : h
  {x: far_x, y: far_y}
end

ruby3 notation instead
