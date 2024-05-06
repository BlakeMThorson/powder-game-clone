local json = require("json")
local screen_shot = require("screenshot")
local maze = require("maze")
local eh = require("element_handler")

local button_vc = gdt.VideoChip1
local screen_vc = gdt.VideoChip0
local button_sprites = gdt.ROM.User.SpriteSheets["icons"]
local pd = PixelData.new(screen_vc.Width,screen_vc.Height, color.black)

-- ON START Shenanigans
-- screenshot
button_vc:DrawSprite(vec2(0,0),button_sprites, 0, 0, color.white, color.white)
-- clear screen
button_vc:DrawSprite(vec2(27,0),button_sprites, 1, 0, color.white, color.white)
-- maze
button_vc:DrawSprite(vec2(107,0),button_sprites, 4, 0, color.white, color.white)
-- water
button_vc:DrawSprite(vec2(176,0),button_sprites, 5, 0 , color.white, color.white)
-- gas
button_vc:DrawSprite(vec2(176,26),button_sprites, 8, 0 , color.white, color.white)
-- sand
button_vc:DrawSprite(vec2(202,0),button_sprites, 6, 0 , color.white, color.white)
-- wall
button_vc:DrawSprite(vec2(228,0),button_sprites, 7, 0 , color.white, color.white)


-- UTILITY BUTTONS
-- SCREENSHOT BUTTON
function eventChannel2(sender, event)
	if(gdt.ScreenButton0.ButtonState) then
		screen_shot.take_screenshot(pd)
	end
end
-- Clear all button
function eventChannel8()
	eh.clear_all()
end
-- MAZE BUTTON
function eventChannel3(sender, event)
	if(gdt.ScreenButton2.ButtonState) then
		maze.draw_maze(pd)
	end
end


-- ELEMENT BUTTONS
-- water button
function eventChannel5(sender, event)
	eh.set_current_element("water")
end
-- sand button
function eventChannel6(sender, event)
	eh.set_current_element("sand")
end
-- wall button
function eventChannel7(sender, event)
	eh.set_current_element("wall")
end
--gas button
function eventChannel9(sender, event)
	eh.set_current_element("gas")
end

-- DRAW EVENT
-- handles drawing the element
function eventChannel4(sender, event)
	if screen_vc.TouchState then
		eh.element_draw(pd, screen_vc.TouchPosition.x, screen_vc.TouchPosition.y)
	end
end

-- ON UPDATE FUNCTION, HAPPENS EVERY TICK
function update()
	-- call element handler and pass it the updated PD
	eh.set_pd(pd)
	-- befor elements move, adjust the y for density ( ex: sand sinks in water )
	eh.move_for_density()
	-- now we move the elements
	eh.move_elements_update()
	-- update the pixel data before drawing it
	pd = eh.get_pd()
	screen_vc:SetPixelData(pd)
end
