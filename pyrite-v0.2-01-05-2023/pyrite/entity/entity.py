import pygame
from pyrite.assets.sprite import Sprite
from pyrite.assets.animation_loader import Animation
from pyrite.collision import * 
import time, random

class Entity:
    def __init__(self,size):
        pygame.init()
        self.width, self.height = size[0], size[1]
        
        self.image = None
        self.rect = pygame.Rect(0, 0, 0, 0)
        self.mask = None
        
        self.direction = 'right'
        self.on_ground = False
        self.custom_animation = False
        self.custom_movement = False
        
        self.particle_managers = []
        self.last_movement = (0, 0)
        
    def update_rect(self):
        self.rect.x, self.rect.y = self.x, self.y
    
    def update_position(self):
        self.x, self.y = self.rect.x, self.rect.y
        
    def draw(self, wn, scroll):
        """draws the entity on screen"""
        wn.blit(self.image, ((self.rect.x - self.rect_offset[0]) - scroll[0], (self.rect.y - self.rect_offset[1]) - scroll[1]))
        for manager in self.particle_managers:
            manager.render(wn, scroll)
        
    def load_animation(self, path, rules_path, frame_size, player_size):
        self.animation_loader = Animation()
        self.animation_loader.get_animation(path, rules_path, frame_size, player_size)
    
    def load_images(self, path, rules_path, image_size, animated=False):
        """Gets images from sprite and saves them in a array"""
        self.images = [] 
        if animated:
            self.load_animation(path=path, rules_path=rules_path, frame_size=image_size['frame_size'], player_size=image_size['player_size'])
        else:
            self.image = pygame.transform.scale(pygame.image.load(path), image_size['player_size'])
            self.image.set_colorkey((0,0,0))
            self.rect = self.image.get_rect()
            
        
class PhysicalEntity(Entity):
    def __init__(self, size, movement):
        super().__init__(size)
        
        self.speed = movement['speed']
        self.jump_height = movement['jump_heigth'] 
        self.gravity, self.friction = movement['gravity'], movement['friction']
        self.position, self.velocity = pygame.math.Vector2(self.rect.x, self.rect.y), pygame.math.Vector2(0, 0)
        self.acceleration = pygame.math.Vector2(0, self.gravity)
        
        self.on_ground = False                      
        self.is_falling = False
        self.is_jumping = False
        self.double_jump = True
        self.last_jump = time.time()
    
    def calc_movement(self, ent, keys, dt, tile_list):
        movement_x = 0
        movement_y = 0
        
        self.position.x = self.rect.x
        self.position.y = self.rect.y
        # x movement
        if not self.custom_movement:
            self.acceleration.x = 0
            if keys['move_left']:
                ent.animation = 'run'
                self.direction = 'left'
                self.acceleration.x -= self.speed
            elif keys['move_right']:
                ent.animation = 'run'
                self.direction = 'right'
                self.acceleration.x += self.speed
        self.acceleration.x += self.velocity.x * self.friction
        self.velocity.x += self.acceleration.x * dt
        self.limit_velocity(7, 'x')
        self.position.x += self.velocity.x * dt + (self.acceleration.x * .5) * (dt * dt)
        movement_x = self.position.x - self.rect.x
        if movement_x < 0:
            if movement_x > -0.5: movement_x = 0
        elif movement_x > 0:
            if movement_x < 0.5: movement_x = 0

        # y movement
        if not self.custom_movement:
            if keys['jump']:
                self.jump()
            self.velocity.y += self.acceleration.y * dt
            if self.velocity.y > 16: self.velocity.y = 16
            if self.on_ground:                          
                self.is_falling = False
                self.is_jumping = False
                self.velocity.y = 0
            else:
                self.position.y += self.velocity.y * dt + (self.acceleration.y * .5) * (dt * dt)
            if self.rect.y - self.position.y < 0:
                self.is_falling = True
                self.is_jumping = False
            movement_y = self.position.y - self.rect.y
        else:
            self.acceleration.y += self.velocity.y * self.friction
            self.velocity.y += self.acceleration.y * dt
            self.limit_velocity(7, 'y')
            self.position.y += self.velocity.y * dt + (self.acceleration.y * .5) * (dt * dt)
            movement_y = self.position.y - self.rect.y
            if movement_y < 0:
                if movement_y > -0.5: movement_y = 0
            elif movement_y > 0:
                if movement_y < 0.5: movement_y = 0

        self.on_ground = False
        move(self, movement_x, movement_y, tile_list)
        if not self.custom_animation:
            if self.on_ground and movement_x == 0:
                self.animation_loader.set_animation('idle')
            elif self.on_ground and movement_x != 0:
                self.animation_loader.set_animation('run')
            elif movement_y > 1:
                self.animation_loader.set_animation('fall')
            if keys['jump']:
                self.animation_loader.set_animation('jump')
        
        if self.animation_loader.last_animation == 'fall':
            if self.animation_loader.animation == 'idle' or self.animation_loader.animation == 'run':
                self.animation_loader.set_animation('land')
                for i in range(0, 70):
                    self.particle_managers[0].add((self.rect.x + self.rect_offset[0] + random.randint(0, self.rect.w), self.rect.y + self.rect_offset[1] + self.rect.h))
        
        self.last_movement = (movement_x, movement_y)
            
    def jump(self):
        self.velocity.y -= self.jump_height
    
    def limit_velocity(self, max_vel, direction):
        if direction == 'x':
            min(-max_vel, max(self.velocity.x, max_vel))
            if abs(self.velocity.x) < .01: self.velocity.x = 0
        else:
            min(-max_vel, max(self.velocity.y, max_vel))
            if abs(self.velocity.y) < .01: self.velocity.y = 0
