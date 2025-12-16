from pyrite.entity.player import *

class CustomPlayer(Player):
    def __init__(self, player_data, pos):
        super().__init__(pos, player_data)
        
        self.weapon = None
    
    def give_weapon(self, weapon):
        self.weapon = weapon
        
    def render(self, wn, scroll):
        self.draw(wn, scroll)
        
        if self.weapon:
            self.weapon.draw(wn, scroll)
        
    def update(self, keys, dt, tile_list, scroll):
        self.update_character(keys.key_events, dt, tile_list)
        
        if self.weapon:
            self.weapon.update(keys.mouse_pos, self, scroll)