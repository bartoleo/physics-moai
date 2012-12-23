-- DIRECTIONS HELPER

DIRECTIONS={
	n={id=1, dx=0,  dy=-1, contr="s", baseframe=10,r=-math.pi/2},
	e={id=2, dx=1,  dy=0,  contr="w", baseframe=0,r=0},
	s={id=3, dx=0,  dy=1,  contr="n", baseframe=5,r=math.pi/2},
	w={id=4, dx=-1, dy=0,  contr="e", baseframe=15,r=math.pi}
}
function DIRECTIONS.dir(pid)
	for k,v in pairs(DIRECTIONS) do
		if type(v)=="table" then
		  if v.id==pid then
			  return k
		  end
		end
	end
	return nil
end