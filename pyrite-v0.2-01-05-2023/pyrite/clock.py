import pygame
import time

class Clock:
    def __init__(self, config):
        pygame.init()
        self.max_fps = config['max-fps']
        self.p_clock = pygame.time.Clock()
        self.fps = self.max_fps
        self.dt = 0
        self.frame_length = time.time()
    
    def set_timepoint(self):
        self.frame_length = time.time()
        
    def calculate_dt(self):
        """Calculates the deltatime between each frame"""
        self.dt = time.time() - self.frame_length
        self.dt *= 60
        self.fps = str(int(self.p_clock.get_fps()))
    