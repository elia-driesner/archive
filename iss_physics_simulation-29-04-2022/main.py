import pygame, sys
import math


WN_SIZE = (900, 900)
wn = pygame.display.set_mode(WN_SIZE)

FPS = 90
clock = pygame.time.Clock()

pixel_meter = 12742000 / 230 # 230 pixels = earth width
pixel_meter = pixel_meter / 230

class Object:
    def __init__(self, x, y, height, width, mass, color, image = 0):
        self.mass = mass      
        self.width = width
        self.height = height      
        self.x, self.y = x, y
        self.color = color
        
        self.center = (self.x - self.width / 2, self.y - self.height / 2)
        
        self.start_x = x
        self.start_y = y
        self.start_image = image
        
        self.render = (self.x, self.y)
        
        if image != 0:
            self.image = pygame.transform.scale(image, (self.width, self.height))
            
            self.img_x = self.x
            self.img_y = self.y
            
def calc_gravity(o1, o2):
    r = ((o1.center[0] + o2.center[0]) - (o1.center[1] + o2.center[1])) * pixel_meter
    F = ((6.67428 * 10e-11) * o1.mass * o2.mass) / (r * r)
    print(F)
    
scale = 1

earth = Object(WN_SIZE[0] / 2, WN_SIZE[1] / 2, 230, 230, 5.972 * 10e24, (0, 0, 255), pygame.image.load('Earth.png'))
iss = Object(earth.center[0] - (pixel_meter / 420000), earth.center[1] - (pixel_meter / 420000), scale * 40, scale * 40, 450 * 1000, (100, 100, 100), pygame.image.load('Satelite.png'))

def updateScale():
    earth.width = 230 * round(scale, 1)
    earth.height = 230 * round(scale, 1)
    earth.center = (earth.x - earth.width / 2, earth.y - earth.height / 2)
    earth.image = pygame.transform.scale(earth.start_image, (earth.width, earth.height))
    
    iss.width = 40 * round(scale, 1)
    iss.height = 40 * round(scale, 1)
    iss.center = (iss.x - iss.width / 2, iss.y - iss.height / 2)
    iss.image = pygame.transform.scale(iss.start_image, (iss.width, iss.height))
    iss.render = (iss.x * scale, iss.y * scale)
    iss.center = iss.x - iss.width / 2, iss.y - iss.height / 2

# calc_gravity(earth, iss)

run = True
while run:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False
            sys.exit()
    clock.tick(FPS)
    pygame.display.set_caption(str(round(clock.get_fps(), 2)) + ' FPS')
    
    keys = pygame.key.get_pressed()
    if keys[pygame.K_PLUS]:
        scale += 0.04
    if keys[pygame.K_MINUS]:
        scale -= 0.04
    updateScale()
            
    wn.fill((0, 0, 0))
    wn.blit(earth.image, earth.center)
    wn.blit(iss.image, iss.center)
    
    pygame.display.update()