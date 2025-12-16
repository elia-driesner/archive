import pygame
import random

from .entity import Entity, PhysicalEntity
from ..assets.json_loader import JsonLoader
from ..assets.rect_cutter import cut_rect
from ..particles.particle_manager import LandParticles
from ..assets.palette_swap import PaletteSwap


class Player(PhysicalEntity):
    def __init__(self, pos, player_data):
        self.player_data = player_data
        
        self.character_name = self.player_data['name']
        self.size = self.player_data['size']
        self.movement_data = self.player_data['movement']
        self.assets_path = self.player_data['assets_path']
        player_sprite = self.assets_path + self.player_data['animations']['main']
        self.main_sprite = self.player_data['animations']['main_sprite']
        self.animation_rules_path = self.assets_path + self.player_data['animations']['animation-rules']
        self.animated = self.player_data['animated']
        self.frame_resolution = self.player_data['animations']['frame_resolution']
         
        super().__init__(self.size, self.movement_data)
        
        self.load_images(self.main_sprite, self.animation_rules_path, {'player_size': self.size, 'frame_size': self.frame_resolution}, self.animated)
        self.type = type
        self.skin = 'Standard'
            
        self.paletteSwap = PaletteSwap()
        self.animation = 'idle'
        self.animation_loader.set_animation(self.animation)
        self.animation_loader.update(self)
        self.rect = cut_rect(self.image)
        self.rect_offset = (self.rect.x, self.rect.y)
        self.rect.x, self.rect.y = pos[0], pos[1]
        
        self.particle_managers.append(LandParticles())
        
        # self.change_skin('Business')
        
    def update_player(self, keys, dt, tile_list):
        self.keys = keys
        self.calc_movement(self, keys, dt, tile_list)
        self.animation_loader.update(self, self.direction)
        # self.swap_skin()
    
    def update_character(self, keys, dt, tile_list):
        self.keys = keys
        self.character_update()
        self.calc_movement(self, keys, dt, tile_list)
        self.animation_loader.update(self, self.direction)
        # self.swap_skin()
    
    def swap_skin(self):
        for color in self.skin_parts['Anzug']:
            self.image = self.paletteSwap.swap(self.image, color)
        for color in self.skin_parts['Hut']:
            self.image = self.paletteSwap.swap(self.image, color)
    
    def change_skin(self, skin):
        skins = []
        for skin_name in self.player_data['skins']:
            skins.append(skin_name)
        # old_skin = self.skin
        old_skin = 'Standard'
        new_skin = skin
        
        changing_colors = []
        changing_parts = {}
        for part in self.player_data['colors']:
            for s in self.player_data['colors'][part]:
                if s == old_skin:
                    old_color = self.player_data['colors'][part][s]
            for s in self.player_data['colors'][part]:
                if s == new_skin:
                    new_color = self.player_data['colors'][part][s]
            for i in old_color:
                changing_colors.append({'part': part, 'colors':[i, new_color[old_color.index(i)]]})
        
        for i in changing_colors:
            if not i['part'] in changing_parts:
                part_name = i['part']
                changing_parts[part_name] = []
                changing_parts[part_name].append(i['colors'])
            else:
                changing_parts[part_name].append(i['colors'])
        self.skin_parts = changing_parts
        

def load_player_data(path):
    json_loader = JsonLoader()
    properties = json_loader.read_path(path)        
    
    sprite_path = properties['assets_path'] + properties['animations']['main']
    sprite = pygame.image.load(sprite_path)
    properties['animations']['main_sprite'] = sprite
    
    return properties
