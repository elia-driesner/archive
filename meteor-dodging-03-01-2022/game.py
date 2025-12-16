import pygame
import random

pygame.init()

clock = pygame.time.Clock()
FPS = 60

wn = pygame.display.set_mode((600, 600))

run = True

gravity = "down"

class Player(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.vel = 4
        self.image = pygame.transform.scale(pygame.image.load("player.png"), (35, 35))
        self.rect = self.image.get_rect()
        self.mask = pygame.mask.from_surface(self.image)
        self.x = 100
        self.y = 100
        
        self.lifes = 3

    def move(self):
        key = pygame.key.get_pressed()
        if key[pygame.K_d]:
            self.x += self.vel
        elif key[pygame.K_a]:
            self.x -= self.vel


        self.rect.x = self.x
        self.rect.y = self.y

    def flip(self):
        self.image = pygame.transform.flip(self.image, False, True)

class Floor(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()

        self.image = pygame.transform.scale(pygame.image.load("floor.png"), (55, 55))
        self.rect = self.image.get_rect()
        self.mask = pygame.mask.from_surface(self.image)

        directions = ["up", "down"]
        self.direction = random.choice(directions)

        if self.direction == "down":
            self.y = -70
        else:
            self.y = 670

        self.x = random.randint(30, 570)

        self.rect.x = self.x
        self.rect.y = self.y
    def move(self):


        if self.direction == "down":
            self.y += 2
        else:
            self.y -= 2

        self.rect.x = self.x
        self.rect.y = self.y




player = Player()

meteor_list = []
for i in range(0, 8):
    meteor_list.append(Floor())

last_key = "up"


while run:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            run = False
            pygame.quit()

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE and last_key == "up":
                last_key = "down"
                if gravity == "up":
                    gravity = "down"
                    player.flip()
                else:
                    player.flip()
                    gravity = "up"

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                last_key = "up"


    spawn = random.randint(70, 110)
    if spawn == 100:
        meteor_list.append(Floor())

    player.move()
    wn.fill((0, 0, 0))    
    wn.blit(player.image, (player.x, player.y))
    for meteor in meteor_list:
        meteor.move()
        wn.blit(meteor.image, (meteor.x, meteor.y))
        meteor_sprite = pygame.sprite.GroupSingle(meteor)
        player_group = pygame.sprite.GroupSingle(player)

        if pygame.sprite.spritecollide(player_group.sprite, meteor_sprite, False, pygame.sprite.collide_mask):
            player.lifes -= 1
            if player.lifes == 0:
                run = False                                  
        else:
            if gravity == "down":
                player.y += player.vel / len(meteor_list)
            else:
                player.y -= player.vel / len(meteor_list)



    clock.tick(FPS)
    pygame.display.update()
