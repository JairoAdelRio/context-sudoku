if not modules then modules = { } end modules ['t-sudoku'] = 
{
    version   = "2021-04-12",
    comment   = "Sudokus for ConTeXt",
    author    = "Jairo A. del Rio",
    copyright = "Jairo A. del Rio",
    license   = "GNU General Public License v3"
}

local table    = table
local math     = math
local io       = io

local ipairs   = ipairs
local pairs    = pairs
local tostring = tostring

local floor    = math.floor
local ceil     = math.ceil

local insert   = table.insert
local concat   = table.concat
local sort     = table.sort

--ConTeXt goodies 
local context    = context       
local interfaces = interfaces
local implement  = interfaces.implement

local contains   = table.contains
local copy       = table.copy
local unique     = table.unique

local loaddata   = io.loaddata

local rows     = {"A", "B", "C", "D", "E", "F", "G", "H", "I"}
local columns  = {"1", "2", "3", "4", "5", "6", "7", "8", "9"}

local rowsquare    =
    {{"A", "B", "C"},
    {"D", "E", "F"},
    {"G", "H", "I"}}

local columnsquare = 
    {{"1", "2", "3"}, 
    {"4", "5", "6"}, 
    {"7", "8", "9"}}

local digits   = '123456789'

-- Helper functions 
-- F#ck Python
local shuffle, string_to_table, cross

shuffle = function(t)
    for i = #t, 2, -1 do
        local j = random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

string_to_table = function(s)
    local result = {}
    s = s:gsub("[.%d]", function(x)
        if x == "." then
            insert(result, x)
        else
            insert(result, tostring(floor(x)))
        end
    end)
    return result 
end

cross = function(t1, t2)
    local result = {}
    for _, a in ipairs(t1) do
        for __, b in ipairs(t2) do
            insert(result, a .. b)
        end
    end
    return result
end

-- Data
local squares, unitlist, units 

squares = cross(rows, columns)

unitlist = {}

for _, c in ipairs(columns) do
    insert(unitlist, cross(rows, {c}))
end
for _, r in ipairs(rows) do
    insert(unitlist, cross({r}, columns))
end
for _, rs in ipairs(rowsquare) do
    for __, cs in ipairs(columnsquare) do
        insert(unitlist, cross(rs, cs))
    end
end

units = {}

for _, s in ipairs(squares) do
    for __, u in ipairs(unitlist) do
        if contains(u, s) then
            if not units[s] then
                units[s] = {}
            end
            insert(units[s], u)
        end
    end
end

--Also works 
local peers = {}

for _, s in ipairs(squares) do
    local unit_set = {}
    for __, unit in ipairs(units[s]) do
        for ___, square in ipairs(unit) do
            if square ~= s then
                insert(unit_set, square)
            end
        end
    end
    peers[s] = unique(unit_set)
end

local   grid_chars, grid_values, parse_grid, assign, 
        eliminate, solve, search

--It works. Don't change it 
--Input: a string representation 
--Output: an association between squares and characters
grid_values = function(grid)
    local result = {}
    local chars  = string_to_table(grid)
    assert(#chars == 81, "Invalid grid")
    --ipairs is necessary here 
    for k, v in ipairs(squares) do
        result[v] = chars[k]
    end
    return result
end

--Input: a table grid 
--Output: return false if contradiction
parse_grid = function(grid)
    local values = {}
    local gridvalues = grid_values(grid)
    --Every square can be any digit 
    for _, s in ipairs(squares) do
        values[s] = digits
    end
    for s, d in pairs(gridvalues) do
        if digits:find(d) and not assign(values, s, d) then
            return false
        end
    end
    return values
end

--It WORKS. DON'T TOUCH IT 
assign = function(values, s, d)
    --Eliminate all the other values and propagate
    local result = true
    local other_values = string_to_table(values[s]:gsub(d,''))
    for _, d2 in ipairs(other_values) do
        if not eliminate(values, s, d2) then
            result = false
        end
    end
    if not result then
        return false
    else
        return values 
    end
end

--IT ALSO WORKS. PLZ DON'T TOUCH IT
eliminate = function(values, s, d)
    --Eliminate d from values[s]
    if not values[s]:find(d) then
        return values --Already eliminated
    end
    values[s] = values[s]:gsub(d,'')
    --[[1. If a square s is reduced to one value d2, then
        eliminate d2 from the peers]]
    if #values[s] == 0 then
        return false 
    elseif #values[s] == 1 then
        local check = true
        local d2 = values[s]
        for _, s2 in pairs(peers[s]) do
            if not eliminate(values, s2, values[s]) then
               check = false
            end 
        end
        if not check then return false end
    end
    --[[2. If a unit u is reduced to only one place for a
        value d, then put it there]]
    for _, u in ipairs(units[s]) do
        local dplaces = {}
        for __, w in ipairs(u) do
            if values[w]:find(d) then
                insert(dplaces, w)
            end
        end
        if #dplaces == 0 then
            return false --contradiction
        elseif #dplaces == 1 then
            if not assign(values, dplaces[1], d) then
                return false
            end
        end
    end
    return values 
end

solve = function(grid)
    return search(parse_grid(grid))
end

search = function(values)
    local check = true
    local n = {}
    local s 
    if not values then
        return false --Fail
    end
    for _, s in ipairs(squares) do
        if #values[s] ~= 1 then
            check = false
        end
    end
    if check then return values end --Solved!
    for _, x in ipairs(squares) do
        if #values[x] > 1 then
            insert(n, {#values[x], x})
        end
    end
    sort(n, function(t1,t2) return t1[1] < t2[1] end)
    s = n[1][2]
    for _, d in ipairs(string_to_table(values[s])) do
        local result = search(assign(copy(values), s, d))
        if result then return result end
    end
    return false
end 

--[[
ConTeXt functions
]]

local ctx_sudoku, ctx_solvesudoku, 
      ctx_sudokufile, ctx_solvesudokufile, ctx_typeset

ctx_typeset = function(s)
    local settings = {
        {
            background="color",
            backgroundcolor=[[\sudokuparameter{backgroundcolor}]],
        },
        {}
    }
    for i, a in ipairs(rows) do
        context.bTR()
        for j, b in ipairs(columns) do
            local r = s[a..b]
            context.bTD(settings[(ceil(i/3)+ceil(j/3))%2+1])
            context(r == '0' and "" or r == '.' and "" or r)
            context.eTD()
        end
        context.eTR()
    end
end

ctx_sudoku = function(s)
    ctx_typeset(grid_values(s))
end

ctx_sudokufile = function(file)
    ctx_typeset(grid_values(loaddata(file)))
end

ctx_solvesudoku = function(s)
    ctx_typeset(solve(s))
end

ctx_solvesudokufile = function(file)
    ctx_typeset(solve(loaddata(file)))
end

implement{
    name      = "sudoku",
    arguments = {"string"},
    actions   = ctx_sudoku 
}

implement{
    name      = "sudokufile",
    arguments = {"string"},
    actions   = ctx_sudokufile 
}

implement{
    name      = "solvesudoku",
    arguments = {"string"},
    actions   = ctx_solvesudoku 
}

implement{
    name      = "solvesudokufile",
    arguments = {"string"},
    actions   = ctx_solvesudokufile
}