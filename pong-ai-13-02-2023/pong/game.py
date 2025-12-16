import pygame
import sys
pygame.init()

from .ball import Ball
from .paddle import Paddle

class GameInformation:
    def __init__(self, left_hits, right_hits, left_score, right_score):
        self.left_hits = left_hits
        self.right_hits = right_hits
        self.left_score = left_score
        self.right_score = right_score
    
class Game():
    def __init__(self, window):
        # initializing variables
        self.FPS = 60
        self.WINDOW_SIZE = [1100, 700]
        self.SCORE_FONT = pygame.font.SysFont("comicsans", 50)

        self.window = window
        # self.window = pygame.display.set_mode(self.WINDOW_SIZE)
        pygame.display.set_caption('Pong AI')
        self.clock = pygame.time.Clock()

        self.ball = Ball(self.WINDOW_SIZE[0] / 2, self.WINDOW_SIZE[1] / 2)
        self.paddle_left = Paddle(30, (self.WINDOW_SIZE[1] / 2) - 50)
        self.paddle_right = Paddle(self.WINDOW_SIZE[0] - 30 - 20, (self.WINDOW_SIZE[1] / 2) - 50)
        
        self.left_score = 0
        self.right_score = 0
        self.left_hits = 0
        self.right_hits = 0
        
        self.last_hit = 'center'
        
    def collision(self):
        if self.ball.y <= 0:
            self.ball.y_speed *= -1
        if self.ball.y >= self.WINDOW_SIZE[1]:
            self.ball.y_speed *= -1
            
        if self.ball.x <= 0:
            self.right_score += 1
            self.ball.reset(self.WINDOW_SIZE[0] / 2, self.WINDOW_SIZE[1] / 2, self.ball.x_speed * -1, self.ball.y_speed * 1)
        if self.ball.x >= self.WINDOW_SIZE[0]:
            self.left_score += 1
            self.ball.reset(self.WINDOW_SIZE[0] / 2, self.WINDOW_SIZE[1] / 2, self.ball.x_speed * -1, self.ball.y_speed * 1)
        
        collide = pygame.Rect.colliderect(self.paddle_left.rect, self.ball.rect)
        if collide:
            if self.last_hit != 'left':
                self.left_hits += 1
            self.last_hit = 'left'
            self.ball.x_speed *= -1
            self.ball.x += 5
            self.ball.y += 5
        
        collide = pygame.Rect.colliderect(self.paddle_right.rect, self.ball.rect)
        if collide:
            if self.last_hit != 'right':
                self.right_hits += 1
            self.last_hit = 'right'
            self.ball.x_speed *= -1
            self.ball.x -= 5
            self.ball.y += 5
    
    def draw_dashed_line(self, start, end):
        origin = start
        target = end
        displacement = target[1] - origin[1]
        length = displacement
        slope = displacement/length

        for index in range(0, int(length / 10), 2):
            start_continue = origin[1] + (slope * index * 12)
            end_continue   = origin[1] + (slope * (index + 1) * 12)
            pygame.draw.line(self.window, (255, 255, 255), (self.WINDOW_SIZE[0] / 2, start_continue), (self.WINDOW_SIZE[0] / 2, end_continue), 2)     
        
    def draw_score(self, hits):
        if (hits != 'hits'):
            left_score_text = self.SCORE_FONT.render(f"{self.left_score}", 1, (255, 255, 255))
            right_score_text = self.SCORE_FONT.render(f"{self.right_score}", 1, (255, 255, 255))
        else:
            left_score_text = self.SCORE_FONT.render(f"{self.left_hits}", 1, (255, 255, 255))
            right_score_text = self.SCORE_FONT.render(f"{self.right_hits}", 1, (255, 255, 255))
        
        self.window.blit(left_score_text, (self.WINDOW_SIZE[0] // 4 - left_score_text.get_width() // 2, 20))
        self.window.blit(right_score_text, (self.WINDOW_SIZE[0] * (3/4) - right_score_text.get_width() // 2, 20))
    
    def draw(self, hits):
        self.draw_score(hits)
        self.draw_dashed_line((self.WINDOW_SIZE[0] / 2, 0), (self.WINDOW_SIZE[0] / 2, self.WINDOW_SIZE[1]))
        self.ball.draw(self.window)
        self.paddle_left.draw(self.window)
        self.paddle_right.draw(self.window)
        pygame.display.update()
        self.window.fill((0, 0, 0))
    
    def move(self):
        self.paddle_left.move(self.WINDOW_SIZE, 'left')
        self.paddle_right.move(self.WINDOW_SIZE, 'right')
        
    def player_ai_move(self, direction):
        self.paddle_left.move(self.WINDOW_SIZE, 'left')
        self.paddle_right.ai_move(direction, self.WINDOW_SIZE, 'right')
        
    def ai_move(self, output1, output2):
        self.paddle_left.ai_move(output1, self.WINDOW_SIZE, 'left')
        self.paddle_right.ai_move(output2, self.WINDOW_SIZE, 'right')
    
    def loop(self):
        self.clock.tick(self.FPS)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
                pygame.quit()
                sys.exit()
                
        self.ball.move()
        self.collision()          
        # self.move()
        # self.draw()
        
        game_info = GameInformation(
            self.left_hits, self.right_hits, self.left_score, self.right_score)

        return game_info
        