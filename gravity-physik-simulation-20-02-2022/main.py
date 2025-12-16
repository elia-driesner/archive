import pygame
import os
import time

pygame.init()
pygame.font.init()
os.system('clear')

font = pygame.font.SysFont('menlo', 25)
wn_size = [1400, 700]
wn = pygame.display.set_mode(wn_size)
pygame.display.set_caption('gravity physic simulation')

clock = pygame.time.Clock()
FPS = 60

run = True

pixel_meter = (6371 * 1000) / 300

objects = []

class Object:
    def __init__(self, x, y, height, width, mass, color, image = 0):
        self.mass = mass      
        self.width = width
        self.height = height      
        self.x, self.y = x, y
        self.color = color
        
        self.start_x = x
        self.start_y = y
        
        if image != 0:
            self.image = pygame.transform.scale(image, (self.width, self.height))
            
            self.img_x = self.x
            self.img_y = self.y
            print(self.img_y)
        
        
def calc_gravity(m1, m2, r, o1, o2, speed):
    speed = speed
    F = ((6.67428 * 10e-11) * m1 * m2) / (r * r)
    t = 0.0166666667 * speed
    a = F / m2
    s = a * t * t
    distance = round((((o1.x) - (o2.x + (o2.width))) * (pixel_meter / 300)) / 1000, 2)
    velocity = round((s / t) * 3.6, 2)
    gravity = round(F, 2)
    energy = F * s
    print(energy)
    
    o1_x = o1.x
    o2_x = o2.x - (o2.width / 2)

    if o2_x < o1_x:
        o2.x += (s)
    else: 
        o2.x += (s)
        
    return [distance, velocity, gravity, speed]
    
objects.append(Object(1100, (wn_size[1] / 2) - 300, 600, 600, 5.972 * 10e24, (0, 0, 255), pygame.image.load('Erth.png')))

objects.append(Object(0, (wn_size[1] / 2) - 10, 40, 40, 60, (0, 255, 0), pygame.image.load('Meteor.png')))

speed = 1
last_time = time.time()

while run:  
    keys = pygame.key.get_pressed()
    if keys[pygame.K_PLUS] and ((last_time - time.time()) * -1) > 0.1:
        speed += 1
        last_time = time.time()
    elif keys[pygame.K_MINUS] and ((last_time - time.time()) * -1) > 0.1:
        if speed != 1:
            speed -= 1
            last_time = time.time()
    wn.fill((0, 0, 0))
    for element in objects:
        if element != objects[0]:
            wn.blit(element.image, (element.x, element.y))
        else:
            # pygame.draw.circle(wn, element.color, (element.x, element.y), element.width)
            wn.blit(element.image, (element.img_x, element.img_y))
    
    data = calc_gravity(m1 = objects[0].mass , m2 = objects[1].mass, r =  pixel_meter * ((objects[0].x + (objects[0].width / 2)) - (objects[1].x + (objects[1].width / 2))), o1 = objects[0], o2 = objects[1], speed = speed)
    clock.tick(FPS)
    text = []
    pos = 0
    for i in range(0, 4):
        if i == 0:
            text.append(font.render(f'Distance r = {data[0]}km', True, (255, 255, 255)))
        elif i == 1:
            text.append(font.render(f'Velocity v = {round(data[1] / speed, 2)}km/h', True, (255, 255, 255)))
        elif i == 2:
            text.append(font.render(f'Gravity F = {data[2]}N', True, (255, 255, 255)))
        elif i == 3:
            text.append(font.render(f'Speed = x{data[3]}', True, (255, 255, 255)))
            
    for text in text:
        wn.blit(text, (0, pos))
        pos += 30
    pygame.display.update()
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False
            pygame.quit()
            
            
    