local html_colors = require("html_colors")

local element_handler = { _version = "0.1.0" }

-- keep track of placed elements
local gas_particles = {}
local water_particles = {}
local sand_particles = {}
local cement_particles = {}

-- Element Colors so they are easily changed
local gas_color = html_colors.deeppink
local water_color = html_colors.blue
local sand_color = html_colors.darkgoldenrod
local cement_color = html_colors.gray
local wall_color = html_colors.ghostwhite

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
  gas_particles = {}
  water_particles = {}
  sand_particles = {}
  cement_particles = {}
  pd = PixelData.new(screen_vc.Width, screen_vc.Height, color.black)
end

-- the element we are using
local current_element = nil

function element_handler.set_current_element(element)
  current_element = element
end

-- drawing elements on screen and adding to tables
function element_handler.element_draw(pd, x, y)
  -- Don't draw elements over each other

  -- HANDLE "BRUSH SIZE"
  local spread_amount = map_and_round(gdt.Slider0.Value, 0, 100, 1, 4)
  local spread = 0
  if not (spread_amount == 1) then
    spread = math.random(-spread_amount, spread_amount)
  end

  if get_color(x + spread, y) == color.black then
    -- Drawing Gas
    if current_element == "gas" then
      table.insert(gas_particles, {x = x + spread, y = y})
      pd:SetPixel(x + spread, y, gas_color)
    -- Drawing Water
    elseif current_element == "water" then
      table.insert(water_particles, {x = x + spread, y = y})
      pd:SetPixel(x + spread, y, water_color)
    -- Drawing Sand
    elseif current_element == "sand" then
      table.insert(sand_particles, {x = x + spread, y = y})
      pd:SetPixel(x + spread, y, sand_color)
    -- Drawing Cement
    elseif current_element == "cement" then
      table.insert(cement_particles, {x = x + spread, y = y})
      pd:SetPixel(x + spread, y, cement_color)
    -- Drawing Walls
    elseif current_element == "wall" then
      pd:SetPixel(x, y, wall_color)
    end
  end
end

-- HANDLE MOVING AND UPDATING GAS-LIKE ELEMENTS
function element_handler.move_and_update_gas_like(particle, index)
  local choice = math.random(1, 2)
  pd:SetPixel(particle.x, particle.y, color.black)
  -- prioritize moving up
  if particle.y - 1 > 0 and pd:GetPixel(particle.x, particle.y - 1) == color.black then
    gas_particles[index].y = gas_particles[index].y - 1
  -- left
  elseif particle.x - 1 > 1 and particle.y - 1 > 0 and pd:GetPixel(particle.x - 1, particle.y - 1) == color.black then
    if not has_wall(particle.x, particle.y, -1, 0) and not has_wall(particle.x, particle.y, 0, 1) then
      gas_particles[index].x = gas_particles[index].x - 1
      gas_particles[index].y = gas_particles[index].y - 1
    end
  -- right
  elseif particle.x + 1 < pd.Width and particle.y - 1 > 0 and pd:GetPixel(particle.x + 1, particle.y - 1) == color.black then
    if not has_wall(particle.x, particle.y, 1, 0) and not has_wall(particle.x, particle.y, 0, 1) then
      gas_particles[index].x = gas_particles[index].x + 1
      gas_particles[index].y = gas_particles[index].y - 1
    end
  else
    if choice == 1 and particle.x - 1 > 1 and pd:GetPixel(particle.x - 1, particle.y) == color.black then
      gas_particles[index].x = gas_particles[index].x - 1
    elseif choice == 2 and particle.x + 1 < pd.Width and pd:GetPixel(particle.x + 1, particle.y) == color.black then
      gas_particles[index].x = gas_particles[index].x + 1
    end
  end
  pd:SetPixel(gas_particles[index].x, gas_particles[index].y, gas_color)
end

-- HANDLE MOVING AND UPDATING WATER-LIKE ELEMENTS
function element_handler.move_and_update_water_like(particle, index)
  local choice = math.random(1, 2)
  pd:SetPixel(particle.x, particle.y, color.black)
  -- prioritize moving down
  if particle.y + 1 < pd.Height and pd:GetPixel(particle.x, particle.y + 1) == color.black then
    water_particles[index].y = water_particles[index].y + 1
  -- left
  elseif particle.x - 1 > 1 and particle.y + 1 < pd.Height and pd:GetPixel(particle.x - 1, particle.y + 1) == color.black then
    if not has_wall(particle.x, particle.y, -1, 0) and not has_wall(particle.x, particle.y, 0, 1) then
      water_particles[index].x = water_particles[index].x - 1
      water_particles[index].y = water_particles[index].y + 1
    end
  -- right
  elseif particle.x + 1 < pd.Width and particle.y + 1 < pd.Height and pd:GetPixel(particle.x + 1, particle.y + 1) == color.black then
    if not has_wall(particle.x, particle.y, 1, 0) and not has_wall(particle.x, particle.y, 0, 1) then
      water_particles[index].x = water_particles[index].x + 1
      water_particles[index].y = water_particles[index].y + 1
    end
  else
    if choice == 1 and particle.x - 1 > 1 and pd:GetPixel(particle.x - 1, particle.y) == color.black then
      water_particles[index].x = water_particles[index].x - 1
    elseif choice == 2 and particle.x + 1 < pd.Width and pd:GetPixel(particle.x + 1, particle.y) == color.black then
      water_particles[index].x = water_particles[index].x + 1
    end
  end
  pd:SetPixel(water_particles[index].x, water_particles[index].y, water_color)
end

-- HANDLE MOVING AND UPDATING SAND-LIKE ELEMENTS
function element_handler.move_and_update_sand_like(particle, index)
  pd:SetPixel(particle.x, particle.y, color.black)
  -- prioritize moving down
  if particle.y + 1 < pd.Height and pd:GetPixel(particle.x, particle.y + 1) == color.black then
    sand_particles[index].y = sand_particles[index].y + 1
  -- it should move diagonal down if possible
  elseif particle.x - 1 > 1 and particle.y + 1 < pd.Height and pd:GetPixel(particle.x - 1, particle.y + 1) == color.black then
    if not has_wall(particle.x, particle.y, -1, 0) and not has_wall(particle.x, particle.y, 0, 1) then
      sand_particles[index].x = sand_particles[index].x - 1
      sand_particles[index].y = sand_particles[index].y + 1
    end
  -- otherwise it should try to move diagonal right if possible
  elseif particle.x + 1 < pd.Width and particle.y + 1 < pd.Height and pd:GetPixel(particle.x + 1, particle.y + 1) == color.black then
    if not has_wall(particle.x, particle.y, 1, 0) and not has_wall(particle.x, particle.y, 0, 1) then
      sand_particles[index].x = sand_particles[index].x + 1
      sand_particles[index].y = sand_particles[index].y + 1
    end
  end
  pd:SetPixel(sand_particles[index].x, sand_particles[index].y, sand_color)
end

-- HANDLE MOVING AND UPDATING CEMENT-LIKE ELEMENTS
function element_handler.move_and_update_cement_like(particle, index)
  pd:SetPixel(particle.x, particle.y, color.black)
  -- prioritize moving down
  if particle.y + 1 < pd.Height and pd:GetPixel(particle.x, particle.y + 1) == color.black then
    cement_particles[index].y = cement_particles[index].y + 1
  end
  pd:SetPixel(cement_particles[index].x, cement_particles[index].y, cement_color)
end

-- HANDLE MOVING BASED ON DENSITY
function element_handler.move_for_density()
  -- elements that change with density
  local tables_of_dense_elements = {
    sand_particles,
    water_particles
  }

  for _, element_table in ipairs(tables_of_dense_elements) do
    for i = 1, #element_table do
      local particle = element_table[i]
      -- if the element below the one we are checking is less dense than itself
      if not(get_color(particle.x, particle.y + 1) == color.black) and not(has_wall(particle.x, particle.y, 0, 1)) then
        if get_density(get_color(particle.x, particle.y + 1)) < get_density(get_color(particle.x, particle.y)) then
          -- get the element
          local other_element_color = get_color(particle.x, particle.y + 1)
          local other_element_table = get_table_by_color(other_element_color)
          local other_element_index = get_particle_index(other_element_table, particle.x, particle.y + 1)
          -- swap it around
          if other_element_index then
            other_element_table[other_element_index].y = element_table[i].y
            element_table[i].y = element_table[i].y + 1
          end
        end
      end
    end
  end
end

-- HANDLE MOVING ELEMENTS
function element_handler.move_elements_update()
  -- Moving Gas-like elements
  for i = 1, #gas_particles do
    element_handler.move_and_update_gas_like(gas_particles[i], i)
  end

  -- Moving Water-like elements
  for i = 1, #water_particles do
    element_handler.move_and_update_water_like(water_particles[i], i)
  end

  -- Moving Sand-like elements
  for i = 1, #sand_particles do
    element_handler.move_and_update_sand_like(sand_particles[i], i)
  end

  -- Moving Cement-like elements
  for i = 1, #cement_particles do
    element_handler.move_and_update_cement_like(cement_particles[i], i)
  end
end

-- PRIVATE FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------

-- HANDLE DENSITY BY COLOR
function get_density(local_color)
  local density_table = {
    [color_key(gas_color)] = 10,     -- gas density
    [color_key(water_color)] = 30,   -- water density
    [color_key(sand_color)] = 100,   -- sand density
    [color_key(cement_color)] = 200  -- cement density (example value)
  }
  return density_table[color_key(local_color)]
end

-- HANDLES GETTING THE RELEVANT TABLE BASED ON THE COLOR
function get_table_by_color(local_color)
  if color_key(local_color) == color_key(water_color) then
    return water_particles
  elseif color_key(local_color) == color_key(sand_color) then
    return sand_particles
  elseif color_key(local_color) == color_key(gas_color) then
    return gas_particles
  elseif color_key(local_color) == color_key(cement_color) then
    return cement_particles
  end
  return nil
end

function color_key(elem)
  return elem.r .. "-" .. elem.g .. "-" .. elem.b
end

function map_and_round(value, src_from, src_to, tgt_from, tgt_to)
  return math.floor((((value - src_from) / (src_to - src_from) * (tgt_to - tgt_from)) + tgt_from) + 0.5)
end

function has_wall(x, y, x_mod, y_mod)
  return pd:GetPixel(x + x_mod, y + y_mod) == wall_color
end

function get_color(x, y)
  return pd:GetPixel(x, y)
end

function get_particle_index(tbl, x, y)
  for i, record in ipairs(tbl) do
    if record.x == x and record.y == y then
      return i
    end
  end
  return nil  -- Return nil if no matching record is found
end

return element_handler
