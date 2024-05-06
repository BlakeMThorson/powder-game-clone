local html_colors = require("html_colors")

local element_handler = { _version = "0.1.0" }

-- keep track of placed elements
local water_particles = {}
local sand_particles = {}
local gas_particles = {}

-- Element Colors so they are easily changed
local water_color = html_colors.blue
local sand_color = html_colors.darkgoldenrod
local wall_color = html_colors.ghostwhite
local gas_color = html_colors.deeppink


-- set the PD on update so that we aren't having to constantly pass it around
local pd = {}

function element_handler.set_pd(pixel_data)
  pd = pixel_data
end

function element_handler.get_pd()
  return pd
end

-- handle the clear screen button
function element_handler.clear_all()
  water_particles = {}
	sand_particles = {}
  gas_particles = {}
	pd = PixelData.new(screen_vc.Width,screen_vc.Height, color.black)
end

-- the element we are using
local current_element = nil

function element_handler.set_current_element(element)
  current_element = element 
end

-- drawing elements on screen and adding to tables
function element_handler.element_draw(pd, x, y)
  -- Don't draw elements over eachother

  -- HANDLE "BRUSH SIZE"
  local spread_amount = map_and_round(gdt.Slider0.Value, 0, 100, 1, 4)
  local spread = 0
  if not (spread_amount == 1) then
    spread = math.random(-spread_amount , spread_amount)
  end


  if get_color(x + spread,y) == color.black then
    -- Drawing Water
    if current_element == "water" then
      table.insert(water_particles, {x = x + spread, y = y})
      pd:SetPixel(x + spread, y, water_color)
    -- Drawing Gas
    elseif current_element == "gas" then
      table.insert(gas_particles, {x=x + spread, y=y})
      pd:SetPixel(x + spread, y, gas_color)
    -- DRAWING SAND
    elseif current_element == "sand" then
      table.insert(sand_particles,{x = x + spread, y = y})
      pd:SetPixel(x + spread, y, sand_color)
    -- Drawing Walls
    elseif current_element == "wall" then
      pd:SetPixel(x, y, wall_color)
    end
  end
end

-- HANDLE MOVING AND UPDATING GAS POSITIONS
function element_handler.move_and_update_gas(gas_particle, index)
	local choice = math.random(1,2)
	pd:SetPixel(gas_particle.x,gas_particle.y,color.black)
	-- prioritize moving up
	if gas_particle.y - 1 > 0 and pd:GetPixel(gas_particle.x , gas_particle.y - 1) == color.black then
		gas_particles[index].y = gas_particles[index].y - 1
	-- left
	elseif gas_particle.x - 1 > 1 and gas_particle.y - 1 > 0  and pd:GetPixel(gas_particle.x - 1 , gas_particle.y - 1 ) == color.black then
		if not has_wall(gas_particle.x, gas_particle.y, -1, 0) and not has_wall(gas_particle.x, gas_particle.y, 0, 1) then
      gas_particles[index].x = gas_particles[index].x - 1
		  gas_particles[index].y = gas_particles[index].y - 1
    end
	-- right
	elseif gas_particle.x + 1 < pd.Width and gas_particle.y - 1 > 0 and pd:GetPixel(gas_particle.x + 1 , gas_particle.y - 1 ) == color.black then
		if not has_wall(gas_particle.x, gas_particle.y, 1, 0) and not has_wall(gas_particle.x, gas_particle.y, 0, 1) then
      gas_particles[index].x = gas_particles[index].x + 1
	  	gas_particles[index].y = gas_particles[index].y - 1
    end
  else
    if choice == 1 and gas_particle.x - 1 > 1 and pd:GetPixel(gas_particle.x - 1 , gas_particle.y ) == color.black then
      gas_particles[index].x = gas_particles[index].x - 1
    elseif choice == 2 and gas_particle.x + 1 < pd.Width and pd:GetPixel(gas_particle.x + 1 , gas_particle.y ) == color.black then
      gas_particles[index].x = gas_particles[index].x + 1
    end
	end
	pd:SetPixel(gas_particles[index].x, gas_particles[index].y, gas_color)
end

-- HANDLE MOVING AND UPDATING WATER POSITIONS
function element_handler.move_and_update_water(water_particle, index)
	local choice = math.random(1,2)
	pd:SetPixel(water_particle.x,water_particle.y,color.black)
	-- prioritize moving down
	if water_particle.y + 1 < pd.Height and pd:GetPixel(water_particle.x , water_particle.y + 1) == color.black then
		water_particles[index].y = water_particles[index].y + 1
	-- left
	elseif water_particle.x - 1 > 1 and water_particle.y + 1 < pd.Height  and pd:GetPixel(water_particle.x - 1 , water_particle.y + 1 ) == color.black then
		if not has_wall(water_particle.x, water_particle.y, -1, 0) and not has_wall(water_particle.x, water_particle.y, 0, 1) then
      water_particles[index].x = water_particles[index].x - 1
		  water_particles[index].y = water_particles[index].y + 1
    end
	-- right
	elseif water_particle.x + 1 < pd.Width and water_particle.y + 1 < pd.Height and pd:GetPixel(water_particle.x + 1 , water_particle.y + 1 ) == color.black then
		if not has_wall(water_particle.x, water_particle.y, 1, 0) and not has_wall(water_particle.x, water_particle.y, 0, 1) then
      water_particles[index].x = water_particles[index].x + 1
	  	water_particles[index].y = water_particles[index].y + 1
    end
  else
    if choice == 1 and water_particle.x - 1 > 1 and pd:GetPixel(water_particle.x - 1 , water_particle.y ) == color.black then
      water_particles[index].x = water_particles[index].x - 1
    elseif choice == 2 and water_particle.x + 1 < pd.Width and pd:GetPixel(water_particle.x + 1 , water_particle.y ) == color.black then
      water_particles[index].x = water_particles[index].x + 1
    end
	end
	pd:SetPixel(water_particles[index].x, water_particles[index].y, water_color)
end

-- HANDLE MOVING AND UPDATING SAND
function element_handler.move_and_update_sand(sand_particle,index)
	pd:SetPixel(sand_particle.x,sand_particle.y,color.black)
	-- prioritize moving down
	if sand_particle.y + 1 < pd.Height and pd:GetPixel(sand_particle.x , sand_particle.y + 1) == color.black then
		sand_particles[index].y = sand_particles[index].y + 1
	-- it should move diagonal down if possible
	elseif sand_particle.x - 1 > 1 and sand_particle.y + 1 < pd.Height  and pd:GetPixel(sand_particle.x - 1 , sand_particle.y + 1 ) == color.black then
    if not has_wall(sand_particle.x, sand_particle.y, -1, 0) and not has_wall(sand_particle.x, sand_particle.y, 0, 1) then
		  sand_particles[index].x = sand_particles[index].x - 1
		  sand_particles[index].y = sand_particles[index].y + 1
    end
	-- otherwise it should try to move diagonal right if possible
	elseif sand_particle.x + 1 < pd.Width and sand_particle.y + 1 < pd.Height and pd:GetPixel(sand_particle.x + 1 , sand_particle.y + 1 ) == color.black then
    if not has_wall(sand_particle.x, sand_particle.y, 1, 0) and not has_wall(sand_particle.x, sand_particle.y, 0, 1) then
      sand_particles[index].x = sand_particles[index].x + 1
      sand_particles[index].y = sand_particles[index].y + 1
    end
	end
	pd:SetPixel(sand_particles[index].x, sand_particles[index].y, sand_color)
end

-- HANDLE MOVING BASED ON DENSITY
function element_handler.move_for_density()
  -- elements that change with density
  local tables_of_dense_elements = {
    water_particles,
    sand_particles
  }

  -- iterate over the table of density
  for index, element_table in ipairs(tables_of_dense_elements) do
    -- iterate over each particle present
    for i = 1, #element_table do
      local particle = element_table[i]
      -- if the element below the one we are checking is less dense than itself
      if not(get_color(particle.x, particle.y+1) == color.black) and not(has_wall(particle.x, particle.y, 0, 1)) then
        if get_density(get_color(particle.x, particle.y+1)) < get_density(get_color(particle.x, particle.y)) then
          -- get the element
          local other_element_color = get_color(particle.x, particle.y+1)
          local other_element_table = get_table_by_color(other_element_color)
          local other_element_index = get_particle_index(other_element_table, particle.x, particle.y + 1)
          -- swap it around
          other_element_table[other_element_index].y = element_table[i].y
          element_table[i].y = element_table[i].y + 1
        end
      end
    end
  end
end

-- HANDLE MOVING ELEMENTS
function element_handler.move_elements_update()
  -- if water exists, move it
  if #water_particles > 0 then
		for i = 1 , #water_particles do
			element_handler.move_and_update_water(water_particles[i],i)
		end
	end
  -- if sand exists, move it
	if #sand_particles > 0 then
		for i = 1 , #sand_particles do
			element_handler.move_and_update_sand(sand_particles[i], i)
		end
	end
  -- if gas exists, move it
  if #gas_particles > 0 then
    for i = 1, #gas_particles do
      element_handler.move_and_update_gas(gas_particles[i], i)
    end
  end
end

-- PRIVATE FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------

-- HANDLE DENSITY BY COLOR
function get_density(local_color)
  local density_table = {
    -- gas density 10
    [color_key(gas_color)] = 10,
    -- water density 30
    [color_key(water_color)] = 30,
    -- sand density 100
    [color_key(sand_color)] = 100
  }

  return density_table[color_key(local_color)]
end

-- HANDLES GETTING THE RELEVANT TABLE BASED ON THE COLOR
function get_table_by_color(local_color)
  if local_color == water_color then
    return water_particles
  elseif local_color == sand_color then
    return sand_particles
  elseif local_color == gas_color then
    return gas_particles
  end
end

function color_key(elem)
  return  elem.r .. "-" .. elem.g .. "-" .. elem.b
end

function map_and_round(value, src_from, src_to, tgt_from, tgt_to)
  return math.floor( (((value - src_from) / (src_to - src_from) * (tgt_to - tgt_from)) + tgt_from) + 0.5 )
end

function has_wall(x, y, x_mod, y_mod)
  return pd:GetPixel(x + x_mod , y + y_mod) == wall_color
end

function get_color(x, y)
	return pd:GetPixel(x, y)
end

function get_particle_index(table, x, y)
	local index = nil
	for i = 1, #table do
		if table[i].x == x and table[i].y == y then
			index = i
		end
	end
	return index
end

return element_handler
