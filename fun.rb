#write a function that takes a the dimentions of a field and the coordinates of a point and returns the cooridinates of the farthest point from the given point
def farthest_point(x,y,point_x,point_y)
  if point_x > x/2
    far_x = 0
  else
    far_x = x
  end
  if point_y > y/2
    far_y = 0
  else
    far_y = y
  end
  [far_x,far_y]
end

