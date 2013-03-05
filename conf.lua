function love.conf(t)
    t.title = "That Falling Box Game"        -- The title of the window the game is in (string)
    t.author = "Kingdaro"        -- The author of the game (string)
    t.identity = 'that falling box game'            -- The name of the save directory (string)
    t.console = true           -- Attach a console (boolean, Windows only)
 --   t.release = true           -- Enable release mode (boolean)
    t.modules.physics = false    -- Enable the physics module (boolean)
	t.version = '0.8.0'
end