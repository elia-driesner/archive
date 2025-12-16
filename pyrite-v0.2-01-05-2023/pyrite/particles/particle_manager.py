import pygame
import random

from .particle import Particle

class ParticleManager:
    def __init__(self):
        self.particles = []
        
    def add_particle(self, particle):
        self.particles.append(particle)
    
    def random_speed(self, speed, x=0, y=0, flat=False):
        random_x = random.randint((speed * 1000) * -1, speed * 1000) / 1000 -1
        random_y = random.randint((speed * 1000) * -1, speed * 1000) / 1000 -1
        
        if x == -1:
            if random_x > 0:
                random_x *= -1
        if x == 1:
            if random_x < 0:
                random_x *= -1
        if y == -1:
            if random_y > 0:
                random_y *= -1
        if y == 1:
            if random_y < 0:
                random_y *= -1
        
        if flat:
            random_y += 0.9
        
        return (random_x, random_y)
    
    
class LandParticles(ParticleManager):
    def __init__(self):
        super().__init__()
        self.spawn_delay = 0
        self.counter = self.spawn_delay
        self.max_speed = 1
        self.radius = 3
        
    def add(self, pos):
        if self.counter <= 0:
            self.add_particle(Particle(pos, self.random_speed(self.max_speed, y=-1, flat=True), self.radius))
            self.counter = self.spawn_delay
        self.counter -= 1
        
    def subtract_duration(self, particle):
        particle.duration -= 0.1
        
    def render(self, window, scroll):
        window = window
        
        for particle in self.particles:
            particle.calc_pos()
            if particle.duration <= 0:
                self.particles.pop(self.particles.index(particle))
            pygame.draw.circle(window, (255, 255, 255), (particle.x - scroll[0], particle.y - scroll[1]), particle.duration)
            self.subtract_duration(particle)