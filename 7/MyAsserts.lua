function vectorEquals(a, b)
	assert(a ~= nil, "Nil values not allowed: a")
	assert(b ~= nil, "Nil values not allowed: b")
	return (a-b):length() == 0
end
