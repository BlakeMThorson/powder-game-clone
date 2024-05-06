local maze = { _version = "0.1.0" }
local vc = gdt.VideoChip0
local height = vc.Height
local width = vc.Width
local offset = 75

local cells = {}

-- Function to draw the maze
function maze.draw_maze(pd)
    -- White out the play area
    white_play_area(pd)
    
    -- Carve the maze
    carve_maze(pd)
    
    -- Draw the pixel data
    print("done maze gen")
    vc:SetPixelData(pd)
end

-- Function to set the play area white
function white_play_area(pd)    
    for i = 1, width, 2 do
        cells[i] = {}
        for j = 1, height, 2 do
            cells[i][j] = {x = i, y = j, visited = false}
            -- Set only odd cells white, leaving walls intact
            pd:SetPixel(i, j + offset, color.black)
        end
    end
end

-- Function to carve out the maze
function carve_maze(pd)
    local current_cell = cells[math.floor(#cells/2+0.5)][offset]
    cells[math.floor(#cells/2+0.5)][offset].visited = true
    local cell_stack = {current_cell}
    
    while #cell_stack > 0 do
        current_cell = table.remove(cell_stack)
        local neighbors = get_neighbors(current_cell)
        
        if #neighbors > 0 then
            table.insert(cell_stack, current_cell)
            local unvisited_neighbor = neighbors[math.random(#neighbors)]
            remove_wall(current_cell, unvisited_neighbor, pd)
            cells[unvisited_neighbor.x][unvisited_neighbor.y].visited = true
            table.insert(cell_stack, unvisited_neighbor)
        end
    end
end

-- Function to remove walls between the current cell and the neighbor
function remove_wall(current_cell, unvisited_neighbor, pd)
    local wall_x = (current_cell.x + unvisited_neighbor.x) / 2
    local wall_y = (current_cell.y + unvisited_neighbor.y) / 2
    
		if( not (wall_y < offset)) then
   	 pd:SetPixel(wall_x, wall_y, color.white)
		end
		if( not (unvisited_neighbor.y < offset)) then
    	pd:SetPixel(unvisited_neighbor.x, unvisited_neighbor.y, color.white)
		end
end

-- Function to get unvisited neighbors two cells away
function get_neighbors(current_cell)
    local neighbors = {}
    
    local directions = {
        {x = 0, y = -2}, -- Up
        {x = 2, y = 0},  -- Right
        {x = 0, y = 2},  -- Down
        {x = -2, y = 0}  -- Left
    }
    
    for _, dir in ipairs(directions) do
        local nx, ny = current_cell.x + dir.x, current_cell.y + dir.y
        if nx > 0 and ny > 0 and nx <= width and ny <= height and not cells[nx][ny].visited then
            table.insert(neighbors, cells[nx][ny])
        end
    end
    
    return neighbors
end

return maze
