function love.conf(t)

	t.title             = "Station Architect"
	t.author            = "TheLife"
	t.version           = "11.2"
	t.identity          = "station-architect"
	
	t.console           = true	 
	t.modules.joystick  = false    
    t.modules.audio     = true      
    t.modules.keyboard  = true   
    t.modules.event     = true      
    t.modules.image     = true      
    t.modules.graphics  = true   
    t.modules.timer     = true      
    t.modules.mouse     = true      
    t.modules.sound     = true      
    t.modules.physics   = false
	t.window.vsync      = false
	t.window.resizable  = false
	
end
