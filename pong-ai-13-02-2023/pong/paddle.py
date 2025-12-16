import pygame

class Paddle():
    def __init__(self, x, y,):
        self.color = pygame.Color(255, 255, 255)
        self.x, self.y = x, y
        self.speed = 6
        self.width, self.height = 20, 100
        
        self.rect = pygame.Rect(self.x, self.y, self.width, self.height)
    
    def draw(self, display):
        """
        Draws the player on the screen
        """
        self.rect.x = self.x
        self.rect.y = self.y
        pygame.draw.rect(display, self.color, self.rect)
        
    def move(self, window_size, side):
        """
        Moving the player according to input if the player doesnt collide with window borders
        """
        if side == 'left':
            keys = pygame.key.get_pressed()
            if keys[pygame.K_w]:
                if (self.y > 0):
                    self.y -= self.speed
            elif keys[pygame.K_s]:
                if (self.y + self.height < window_size[1]):
                    self.y += self.speed
        if side == 'right':
            keys = pygame.key.get_pressed()
            if keys[pygame.K_UP]:
                if (self.y > 0):
                    self.y -= self.speed
            elif keys[pygame.K_DOWN]:
                if (self.y + self.height < window_size[1]):
                    self.y += self.speed
                    
    def ai_move(self, direction, window_size, side):
        if side == 'left':
            if direction == 1:
                if (self.y > 0):
                    self.y -= self.speed
            elif direction == 2:
                if (self.y + self.height < window_size[1]):
                    self.y += self.speed
        if side == 'right':
            if direction == 1:
                if (self.y > 0):
                    self.y -= self.speed
            elif direction == 2:
                if (self.y + self.height < window_size[1]):
                    self.y += self.speed
            
                   
   
           
