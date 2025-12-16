from typing import cast
from numpy import mat
import pygame, sys
import math

pygame.init()

WN_SIZE = (1200, 600)
wn = pygame.display.set_mode(WN_SIZE)

FOV = math.pi / 3
HALF_FOV = FOV / 2
angle = math.pi
x = WN_SIZE[0] / 2
y = WN_SIZE[1] / 2
# CASTED_RAYS = int((WN_SIZE[0] / 2) / 10)
CASTED_RAYS = 120
STEP = FOV / CASTED_RAYS
MAX_DEPTH = 900
TILE_SIZE = 50
SCALE = (WN_SIZE[0] / 2) / CASTED_RAYS

clock = pygame.time.Clock()
FPS = 144

grid = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1],
        [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]

block = 50

def draw_map():
    x = 0
    y = 0
    for row in grid:
        x = 0
        for col in row:
            if col == 1:
                pygame.draw.rect(wn, (255, 255, 255), (x, y, block, block), 0)
            x += block
        y += block
        
def cast_ray():
    start_angle = angle - HALF_FOV
    
    for ray in range(CASTED_RAYS):
        for depth in range(1, MAX_DEPTH):
            target_x = x + (depth * math.cos(start_angle))
            target_y = y + (depth * math.sin(start_angle))
            
            row = int(target_y / TILE_SIZE)
            col = int(target_x / TILE_SIZE)
            
            if row > 11:
                row = 11
            if col > 11:
                col = 11
            if row < 0:
                row = 0
            if col < 0:
                col = 0

            pygame.draw.line(wn, (200, 200, 200), (x, y), (target_x, target_y))
            
            # ray hits the condition
            if grid[row][col] == 1:
                pygame.draw.rect(wn, (0, 255, 0), (col *  TILE_SIZE,
                                            row * TILE_SIZE,
                                            TILE_SIZE,
                                            TILE_SIZE))
                
                wall_height = 21000 / (depth + 0.000001)
                color = 255 / (1 + depth * depth * 0.00003)
                
                pygame.draw.rect(wn, (color, color, color), (600 + ray * SCALE, (WN_SIZE[1] / 2) - wall_height / 2, SCALE, wall_height))
                
                break

    
        start_angle += STEP
            

run = True
while run:
    clock.tick(FPS)
    pygame.display.set_caption(str(round(clock.get_fps())) + ' FPS')
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False
            sys.exit()
    keys=pygame.key.get_pressed()
    if keys[pygame.K_w]:
        y -= 5
    if keys[pygame.K_a]:
        x -= 5
    if keys[pygame.K_d]:
        x += 5
    if keys[pygame.K_s]:
        y += 5
        
            
    # Reset window
    pygame.draw.rect(wn, (100, 100, 100), (600, 300, 600, 300))
    pygame.draw.rect(wn, (150, 150, 150), (600, 0, 600, 300))
    pygame.draw.rect(wn, (0, 0, 0), (0, 0, 600, 600))
    
    # Get mouse pos and move the player
    pos = pygame.mouse.get_pos()
    fov_angle = pos
    
    offset_x = pos[0] - x
    offset_y = pos[1] - y
    
    new_x = x + (100*math.cos(angle))
    new_y = y + (100*math.sin(angle))
    
    angle = int(math.degrees(math.atan2(y-pos[1], x-pos[0]))+180)
    angle = angle * math.pi / 180
    
    # Draws Player and line to the mouse
    pygame.draw.circle(wn, (30, 200, 30), (x, y), 7)
    # pygame.draw.circle(wn, (30, 200, 30), (new_x, new_y), 7)

    # Show the FOV
    pygame.draw.line(wn, (0, 255, 0), (x, y),
                                       (x + (100*math.cos(angle - HALF_FOV)),
                                        y + (100*math.sin(angle - HALF_FOV))), 3)
    
    pygame.draw.line(wn, (0, 255, 0), (x, y),
                                       (x + (100*math.cos(angle + HALF_FOV)),
                                        y + (100*math.sin(angle + HALF_FOV))), 3)
    
    draw_map()
    cast_ray()
    pygame.display.flip()
    