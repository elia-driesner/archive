import pygame
import pyrite

from scripts.character import *
from scripts.weapons import *

class Game:
    def __init__(self):
        pygame.init()
        self.run = True
        pyrite.init(self, 'data/settings')
        
        self.player = assign_character('Carter', self.world.map_output[2])
        self.player.give_weapon(Shotgun(self.player, 'data/assets/weapons/shotgun'))
                
    def render(self):
        self.window.display.blit(game.world.map_surf, (0 - self.camera.scroll[0], 0 - self.camera.scroll[1]))
        self.player.update(self.input, self.clock.dt, self.world.tiles, self.camera.scroll)
        self.camera.set_focus(self.player)
        self.player.draw(self.window.display, self.camera.scroll)
        if self.player.weapon:
            self.player.weapon.draw(self.window.display, self.camera.scroll)
        
        self.window.update()
    
    def loop(self):
        """game loop"""
        self.camera.set_focus(self.player)
        while self.run:
            self.input.events()
            pyrite.update(self)
        
game = Game()
game.loop()