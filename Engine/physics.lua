engine = engine or {}
engine.physics = engine.physics or {}
engine.physics.collisions = {}
engine.physics.colliding = {}

-- -------------------------------------------------------------------------- --
--                                External Use                                --
-- -------------------------------------------------------------------------- --

-- Helper function to check if an entity is within a circle
local function isEntityInCircle(ent, x, y, radius, conly, filter)
    if ent.collider then
        if ent.collider.type == "circle" then
            local centerDistance = utils.Distance(ent.x, ent.y, x, y)
            if centerDistance < ent.collider.radius + radius then
                if filter == nil or filter(ent) then
                    return true
                end
            end
        elseif ent.collider.type == "edge" then
            -- TODO
        end
    elseif conly and utils.Distance(ent.x, ent.y, x, y) < radius then
        if filter == nil or filter(ent) then
            return true
        end
    end
    return false
end

-- Returns the first entity found in the circle or false if none is found.
engine.physics.CircleCheck = function(x, y, radius, colliderOnly, filter)
    local conly = colliderOnly or true

    for _, ent in ipairs(engine.world.entities) do
        if isEntityInCircle(ent, x, y, radius, conly, filter) then
            return ent
        end
    end
    return false
end

-- Returns all entities found in the circle.
engine.physics.CircleCheckAll = function(x, y, radius, colliderOnly, filter)
    local conly = colliderOnly or true
    local results = {}

    for _, ent in ipairs(engine.world.entities) do
        if isEntityInCircle(ent, x, y, radius, conly, filter) then
            table.insert(results, ent)
        end
    end
    return results
end

-- -------------------------------------------------------------------------- --
--                                  Internal                                  --
-- -------------------------------------------------------------------------- --

engine.AddCVar("debug_physics", false, "Enables the display of debug physical information")

engine.physics.CheckCollisions = function()
    local ents = engine.entities.GetAll()
    local collisions = {}
    engine.physics.colliding = {}

    for _, a in ipairs(ents) do
        if a.collider and a.collider.type == "circle" then
            for _, b in ipairs(ents) do
                if a ~= b and b.collider and b.collider.type == "circle" then
                    -- Collision between two circle colliders
                    local centerDistance = utils.Distance(a.x, a.y, b.x, b.y)

                    if centerDistance < a.collider.radius + b.collider.radius then
                        -- Collision!
                        collisions[a] = collisions[a] or {}
                        if not table.contains(collisions[a], b) then
                            table.insert(collisions[a], b)
                        end
                        if not table.contains(engine.physics.colliding, a) then
                            table.insert(engine.physics.colliding, a)
                        end
                    end
                end
            end
        end
    end

    engine.physics.collisions = collisions
end



-- ----------------------------- ! DEPRECATED ! ----------------------------- --
--[[

engine.physics.CheckCollisions = function()
    local ents = engine.entities.GetAll()
    local processed = {}
    local collisions = {}
    engine.physics.colliding = {}
    for _, a in ipairs(ents) do
        -- -------------------------------------------------------------------------- --
        --                                First object                                --
        -- -------------------------------------------------------------------------- --
        if (a.collider ~= nil and a.collider.type ~= nil) then
            if (a.collider.type == "edge") then
                -- -------------------------------------------------------------------------- --
                --                                Edge Collider                               --
                -- -------------------------------------------------------------------------- --
                for __, b in ipairs(ents) do
                    if (a ~= b and b.collider ~= nil and b.collider.type ~= nil and not table.contains(processed, b)) then
                        
                        -- -------------------------------------------------------------------------- --
                        --                                Second object                               --
                        -- -------------------------------------------------------------------------- --
                        if (b.collider.type == "edge") then
                            -- --------------------- Collision between edge and edge -------------------- --

                            -- ------------------------------------ - ----------------------------------- --
                        elseif(b.collider.type == "circle") then
                            -- ------------------- Collision between edge and circle. ------------------- --


                            -- ------------------------------------ - ----------------------------------- --
                        else
                            if (b.collider.unknownTypePosted == nil) then
                                b.collider.unknownTypePosted = true
                                engine.Log("[Physics] Warning! Collider with unknown type detected on entity " .. a.id .. " at (" .. a.x .. "," .. a.y .. ").")
                            end
                        end
                    end
                end
            elseif(a.collider.type == "circle") then
                -- -------------------------------------------------------------------------- --
                --                               Circle Collider                              --
                -- -------------------------------------------------------------------------- --
                for __, b in ipairs(ents) do
                    if (a ~= b and b.collider ~= nil and b.collider.type ~= nil and not table.contains(processed, b)) then
                        
                        -- -------------------------------------------------------------------------- --
                        --                                Second Object                               --
                        -- -------------------------------------------------------------------------- --
                        if (b.collider.type == "edge") then
                            -- -------------------- Collision between circle and edge ------------------- --


                            -- ------------------------------------ - ----------------------------------- --
                        elseif(b.collider.type == "circle") then
                            -- ------------------ Collision between circle and circle. ------------------ --
                            local centerDistance = utils.Distance(a.x, a.y, b.x, b.y)
                            
                            -- If the distance between their centers is less than the sum of their radiuses...
                            if (centerDistance < a.collider.radius + b.collider.radius) then
                                -- Collision!
                                collisions[a] = collisions[a] or {}
                                if (not table.contains(collisions[a], b)) then table.insert(collisions[a], b) end
                                if (not table.contains(engine.physics.colliding, a)) then table.insert(engine.physics.colliding, a) end
                                --if (not table.contains(engine.physics.colliding, b)) then table.insert(engine.physics.colliding, b) end
                            end

                            -- ------------------------------------ - ----------------------------------- --
                        else
                            if (b.collider.unknownTypePosted == nil) then
                                b.collider.unknownTypePosted = true
                                engine.Log("[Physics] Warning! Collider with unknown type detected on entity " .. a.id .. " at (" .. a.x .. "," .. a.y .. ").")
                            end
                        end
                    end
                end
            else
                if (a.collider.unknownTypePosted == nil) then
                    a.collider.unknownTypePosted = true
                    engine.Log("[Physics] Warning! Collider with unknown type detected on entity " .. a.id .. " at (" .. a.x .. "," .. a.y .. ").")
                end
            end
        end
        -- Add this entity to processed list, to avoid redundancy.
        table.insert(a, processed)
    end

    engine.physics.collisions = collisions
end]]
-- ----------------------------- ! DEPRECATED ! ----------------------------- --

-- engine.world.IsWithinBoundaries

engine.physics.ResolveCollisions = function()
    for a,targets in pairs(engine.physics.collisions) do
        for _, b in pairs(targets) do
            engine.physics.RepelObjects(a,b)
        end
    end
end

engine.physics.RepelObjects = function(a, b)

    assert(isent(a), "Invalid entity for collision.")
    assert(isent(b), "Invalid entity for collision.")

    -- Calculate the direction from a to b
    local direction_ab = {x = b.x - a.x, y = b.y - a.y}
    local distance = math.sqrt(direction_ab.x * direction_ab.x + direction_ab.y * direction_ab.y)

    local na = #engine.physics.collisions[a] or 0
    local nb = #engine.physics.collisions[b] or 0
    local num_of_collisions = na + nb

    -- Calculate the overlap based on the sum of radii
    local overlap = a.collider.radius + b.collider.radius - distance

    if overlap > 0 then
        -- Calculate the repel force based on the overlap
        local repel_force = overlap * (0.01 + (0.0001 * num_of_collisions))
        
        -- Normalize the direction
        direction_ab.x = direction_ab.x / distance
        direction_ab.y = direction_ab.y / distance

        -- Apply repelling forces to a and b
        a.x = a.x - direction_ab.x * repel_force
        a.y = a.y - direction_ab.y * repel_force

        b.x = b.x + direction_ab.x * repel_force
        b.y = b.y + direction_ab.y * repel_force
    end
end


engine.physics.SnapToSafePosition = function (ent, precision)
    local MAX_ATTEMPTS = 128
    local PRECISION = precision or 24
    local STEP = 360 / PRECISION
    
    if (ent.collider.type == "circle") then
        for angle = 0, 360, STEP do
            for dist = 1, ent.collider.radius * 2, 2 do
                local radians = math.rad(angle)
                local offsetX = math.cos(radians) * dist
                local offsetY = math.sin(radians) * dist
        
                local targetX = ent.x + offsetX
                local targetY = ent.y + offsetY
        
                local col = engine.physics.CircleCheck(targetX, targetY, ent.collider.radius, true, function(e) return e ~= ent end)
                if (col == false) then
                    ent.x = targetX
                    ent.y = targetY
                    return
                end
            end
        end
    end
    engine.Log("[Physics] Failed to find safe spot for colliding entity " .. ent.id)
end

hooks.Add("OnEngineUpdate", function()
    hooks.Fire("PrePhysicsUpdate")
    hooks.Fire("OnPhysicsUpdate")

    engine.physics.CheckCollisions()
    engine.physics.ResolveCollisions()

    hooks.Fire("PostPhysicsUpdate")
end)


-- -------------------------------------------------------------------------- --
--                                    Debug                                   --
-- -------------------------------------------------------------------------- --

hooks.Add("PostGameDraw", function() 
    if (engine.GetCVar("debug_physics", false) == false) then return end
    
    local cols = {}

    for _, ent in ipairs(engine.world.entities) do
        cols[ent] = false
    end

    for _,ent in ipairs(engine.physics.colliding) do
        cols[ent] = true
    end

    for ent, collision in pairs(cols) do
        if (collision == true) then
            love.graphics.setColor(1,0,0)
        else
            love.graphics.setColor(0,1,0)
        end

        if (ent.collider.type == "circle") then
            love.graphics.circle("line", ent.x, ent.y, ent.collider.radius)
        elseif(ent.collider.type == "edge") then
            -- TODO
        end

        love.graphics.setColor(1,1,1)
        if (ent.bbox and ent.bbox.top and ent.bbox.bottom) then
            love.graphics.rectangle("line", ent.x + ent.bbox.top.x, ent.y + ent.bbox.top.y, ent.bbox.bottom.x - ent.bbox.top.x, ent.bbox.bottom.y - ent.bbox.top.y)
        end
    end

    for a,targets in pairs(engine.physics.collisions) do
        for _,b in ipairs(targets) do
            love.graphics.line(a.x, a.y, b.x, b.y)
        end
    end

end)