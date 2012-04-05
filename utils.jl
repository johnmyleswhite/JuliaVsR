function sequence(a, b, by)
  x = a
  v = {x}
  while x <= b - by
    x = x + by
    v = append(v, x)
  end
  v
end

function pos_x(x)
	if x >= 0
		x
	else
		0
	end
end
