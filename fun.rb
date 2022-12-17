#write a function that takes a the dimentions of a field and the coordinates of a point and returns the cooridinates of the farthest point from the given point

def farthest_point(x, y, x1, y1)
  if x1 > x/2
    x2 = 0
  else
    x2 = x
  end
  if y1 > y/2
    y2 = 0
  else
    y2 = y
  end
  return [x2, y2]
end

x = 10
y = 10
x1 = 9
y1 = 9
puts farthest_point(x, y, x1, y1)


