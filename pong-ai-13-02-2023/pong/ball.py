import pygame
import random

class Ball():
    def __init__(self, x, y):
        self.color = pygame.Color(255, 255, 255)
        self.radius = 10
        self.x, self.y = x, y
        self.x_speed, self.y_speed = random.choice([-7, 7]), random.choice([-7, 7])
        self.rect = pygame.Rect(self.x - self.radius, self.y - self.radius, self.radius*2, self.radius*2)
        
        
    def move(self):
        """
        Moves the ball on the x and y axes by the given speed
        """
        self.x += self.x_speed
        self.y += self.y_speed
        self.rect.x = self.x - self.radius
        self.rect.y = self.y - self.radius
        
    def draw(self, display):
        """
        Draws the ball on the screen
        """
        pygame.draw.circle(display, self.color, [self.x, self.y], self.radius)
    
    def reset(self, x, y, direction_x, direction_y):
        self.x = x
        self.y = y
        
        self.rect.x = x
        self.rect.y = y
        
        self.x_speed = direction_x
        self.y_speed = direction_y
        
        
    