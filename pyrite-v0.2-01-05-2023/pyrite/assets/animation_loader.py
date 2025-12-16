import pygame
from .json_loader import JsonLoader
from .sprite import Sprite

class Animation:
    def __init__(self):
        self.animation_frame = 0
        self.animation = 'idle'
        self.frames = {}
        self.current_direction = 'right'
        self.last_animation = 'idle'
        
    def set_animation(self, animation):
        self.animation = animation
    
    def reset_aniamtion(self):
        self.animation_frame = 0
    
    def set_direction(self, direction):
        self.direction = direction
    
    def reverse_direction(self):
        if self.direction == 'right':
            self.direction = 'left'
        else:
            self.direction = 'right'
    
    def return_animation(self):
        return self.animation

    def get_animation(self, img, rules_path, sprite_size, scale_size):
        """loads the animation from spritesheet and saves infos given in json file with the frames"""
        self.animation_frame = 0
        image = img
        sprite = Sprite(image, sprite_size, sprite_size, (0, 0, 0))
        
        if isinstance(rules_path, str):
            json_loader = JsonLoader()
            rules = json_loader.read_path(rules_path)
        else:
            rules = rules_path
        animation_rules = {}
        
        for animation in rules:
            animation_rules[rules[animation]["row"]] = {
                "name": animation,
                "frame_duration": rules[animation]["frame_duration"],
                "custom_length": rules[animation]["custom_length"]
            }
        
        
        image_size = image.get_size()
        image_cols = image_size[0] // sprite_size[0]
        image_rows = image_size[1] // sprite_size[1]
        
        frames = {
            "unnamed_frames": []
        }
        frame = None
        
        for row in range(0, image_rows):
            temp_row = []
            for col in range(0, image_cols):
                frame = sprite.cut(col, row)
                frame = pygame.transform.scale(frame, scale_size)
                frame_mask = pygame.mask.from_surface(frame)
                frame_pixels = frame_mask.count()
                if frame_pixels != 0:
                    if row in animation_rules:
                        temp_row.append({'frame':frame, 'frame_length': animation_rules[row]['frame_duration']})
                    else:
                        temp_row.append({'frame':frame, 'frame_length': 5})
            if len(temp_row) != 0:
                if row in animation_rules:
                    custom_length = animation_rules[row]["custom_length"]
                    if len(custom_length) != 0:
                        for custom_rule in custom_length:
                            if temp_row[custom_rule[0]]:
                                temp_row[custom_rule[0]]['frame_length'] = custom_rule[1]         
                    frames[animation_rules[row]["name"]] = temp_row
                else:
                    frames["unnamed_frames"].append(temp_row)
        self.frames = frames
    
    def append_animation(self, image_path, frame_size, frame_length, animation_name):
        sprite = pygame.image.load(image_path)
        image_size = sprite.get_size()
        image_cols = image_size[0] // frame_size[0]
        
        row = []
        frame = 0
        
        for i in range(0, image_cols):
            image = pygame.Surface(frame_size)
            image.blit(sprite, (0, 0), ((frame_size[0] * frame), 0, frame_size[0], frame_size[1]))
            image = pygame.transform.scale((image), frame_size)
            image.set_colorkey((0, 0, 0))
            row.append({'frame': image, 'frame_length': frame_length})
            frame += 1
        self.frames[animation_name] = row
    
    def update(self, ent, direction='right'):
        total_frames = 0
        frame_steps = {}
        
        frame_list = self.frames[self.animation]
        
        for frame in frame_list:
            total_frames += frame['frame_length']
            frame_steps[total_frames] = frame
        
        for frame in reversed(frame_steps):
            if self.animation_frame <= frame :
                temp_frame = frame_steps[frame]['frame']
                if direction != self.current_direction:
                    temp_frame = pygame.transform.flip(temp_frame, True, False)    
                ent.image = temp_frame
                
                
        if self.animation_frame > total_frames:
                self.animation_frame = 0
        self.animation_frame += 1
        self.last_animation = self.animation