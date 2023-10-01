engine = engine or {}
engine.physics = engine.physics or {}
engine.physics.collisions = {}
engine.physics.colliding = {}

-- -------------------------------------------------------------------------- --
--                                External Use                                --
-- -------------------------------------------------------------------------- --




-- -------------------------------------------------------------------------- --
--                                  Internal                                  --
-- -------------------------------------------------------------------------- --

engine.AddCVar("debug_physics", false, "Enables the display of debug physical information")

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
end

engine.physics.ResolveCollisions = function()

end

engine.physics.RepelObjects = function ()
    
end

engine.physics.SnapToSafePosition = function ()
    
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