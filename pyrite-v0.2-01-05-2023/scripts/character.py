import pygame 

from pyrite.entity.player import *

from .custom_player import *

def assign_character(name, pos):
    char = None
    basic_path = 'data/assets/player/'
    file_name = '/properties.json'
    combined_path = basic_path + name.lower() + file_name
    if name == 'LightMcSpeed':
        char = LightMcSpeed(load_player_data(combined_path), pos)
    elif name == 'Donald':
        char = LightMcSpeed(load_player_data(combined_path), pos)
    elif name == 'Carter':
        char = Carter(load_player_data(combined_path), pos)
    
    return char
        
class LightMcSpeed(CustomPlayer):
    def __init__(self, player_data, pos):
        super().__init__(player_data, pos)
    
    def character_update(self):
        pass
        
class Donald(CustomPlayer):
    def __init__(self, player_data, pos):
        super().__init__(player_data, pos)
    
    def character_update(self):
        pass
        
class Carter(CustomPlayer):
    def __init__(self, player_data, pos):
        super().__init__(player_data, pos)
        self.is_flying = False
        
    def glide(self):
        if self.animation_loader.animation == 'fall' and self.keys['glide']:
            if self.velocity.y > 5:
                self.velocity.y -= (self.velocity.y - 5) / 2
            
    def fly(self):
        x, y = self.rect.x, self.rect.y
        if self.keys['ability_1'] and self.is_flying:
            self.is_flying = False
            self.custom_movement = False
            self.custom_animation = False
            self.velocity.y = 0
            self.acceleration.x = 0
            self.acceleration = pygame.math.Vector2(0, self.gravity)
            self.animation_loader.set_animation('idle')
            self.animation_loader.update(self)
            self.rect = cut_rect(self.image)
            self.rect_offset = (self.rect.x, self.rect.y)
            self.rect.x, self.rect.y = x, y
            self.animation_loader.set_animation('fall')
        elif self.keys['ability_1']:
            self.is_flying = True
        
        if self.is_flying:
            self.custom_movement = True
            self.custom_animation = True
            self.animation_loader.set_animation('fly')
            self.rect = cut_rect(self.image)
            self.rect_offset = (self.rect.x, self.rect.y)
            self.rect.x, self.rect.y = x, y
            self.acceleration.x = 0
            self.acceleration.y = 0
            custom_speed = self.speed + (self.speed / 3)
            if self.keys['move_left']:
                self.direction = 'left'
                self.acceleration.x -= custom_speed
            elif self.keys['move_right']:
                self.direction = 'right'
                self.acceleration.x += custom_speed
            if self.keys['move_up']:
                self.direction = 'up'
                self.acceleration.y -= custom_speed
            elif self.keys['move_down']:
                self.direction = 'down'
                self.acceleration.y += custom_speed
            
            if self.acceleration.x != 0 and self.acceleration.y != 0:
                dir_x = 1
                dir_y = 1
                if self.acceleration.x < 0:
                    dir_x = -1
                if self.acceleration.y < 0:
                    dir_y = -1
                
                self.acceleration.x = custom_speed * 0.8 * dir_x
                self.acceleration.y = custom_speed * 0.8 * dir_y

            
    def character_update(self):
        self.glide()
        self.fly()
            