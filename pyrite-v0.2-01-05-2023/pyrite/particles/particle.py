import pygame

class Particle:
    def __init__(self, pos, velocity, duration):
        self.x = pos[0]
        self.y = pos[1]
        self.velocity_x = velocity[0]
        self.velocity_y = velocity[1]
        self.duration = duration
    
    def calc_pos(self):
        self.x += self.velocity_x
        self.y += self.velocity_y
        