local tile = {}
tile.template = "base"

tile.segments = {
	[1] = {"f", "i", "n", "nw", "w"},
	[2] = {"f", "i", "e", "n", "ne"},
	[3] = {"f", "i", "s", "sw", "w"},
	[4] = {"f", "i", "e", "s", "se"},
	["full"]  = "wall"
}

function tile:OnCreate()
	-- Snap to grid
	local pos = engine.world.grid.SnapPos(self.x, self.y)
	self.x = pos.x
	self.y = pos.y
end

return tile