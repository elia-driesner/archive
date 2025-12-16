def update(game):
    game.clock.set_timepoint()
    game.clock.p_clock.tick(game.clock.max_fps)
    
    game.camera.calc_scroll()
    game.world.update(game.camera.scroll)
    game.window.reset()
    game.world.map_surf.set_colorkey((0, 0, 0))
    game.render()
    
    game.clock.calculate_dt()