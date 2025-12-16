import pygame
import math
from pyrite.assets.rect_cutter import *
from pyrite.assets.json_loader import *

class Weapon:
    def __init__(self, name, image, config, ent):
        self.name = name
        self.image = image
        self.config = config
        self.carrier = ent
        pos = (self.carrier.rect.x, self.carrier.rect.y)
        
        self.angle = 0
        self.display_img = self.image
        self.rect = cut_rect(self.image)
        self.render_offset = (0, 0)
        self.rect.x, self.rect.y = pos[0], pos[1]
        self.mouse_pos = [0, 0]
        
    def draw(self, wn, scroll):
        print(self.angle)
        wn.blit(pygame.transform.rotate(self.image, self.angle), ((self.rect.x - self.render_offset[0]) - scroll[0], (self.rect.y - self.render_offset[1]) - scroll[1]))
            
    def update(self, mouse_pos, ent, scroll):
        self.mouse_pos = mouse_pos
        self.carrier = ent
        self.calc_angle(scroll)
        self.rect.center = self.carrier.rect.center
    
    def calc_angle(self, scroll):
        dx, dy = self.mouse_pos[0] - ((self.carrier.rect.x + (self.carrier.rect.w / 2)) - scroll[0]), self.mouse_pos[1] - ((self.carrier.y + (self.carrier.rect.h / 2)) - scroll[1])
        angle_radians = math.atan2(dy, dx)
        self.angle = math.degrees(angle_radians) * -1
        self.display_img = pygame.transform.rotate(self.image, self.angle)
        self.rect = self.display_img.get_rect()

class Shotgun(Weapon):
    def __init__(self, ent, path):
        self.path = path
        self.config = read_path(path + '/config.json')
        self.name = self.config['name']
        self.image = pygame.image.load(path + '/' + self.config['image_path'])
        
        super().__init__(self.name, self.image, self.config, ent)