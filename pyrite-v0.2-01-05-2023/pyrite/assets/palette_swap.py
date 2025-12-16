import pygame

class PaletteSwap:
    def __init__(self):
        pass

    def swap(self, input_image, colors):
        image = input_image
        image_size = image.get_size()
        temp_img = pygame.Surface(image_size)
        
        temp_img.fill((0, 0, 0))
        temp_img.blit(image, (0, 0))
        
        temp_surf = pygame.Surface(image_size)
        temp_surf.fill(colors[1])
        temp_img.set_colorkey(colors[0])
        temp_surf.blit(temp_img, (0, 0))
        temp_surf.set_colorkey((0, 0, 0))
        
        return temp_surf
