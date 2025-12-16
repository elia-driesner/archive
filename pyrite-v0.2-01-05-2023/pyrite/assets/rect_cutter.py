import pygame

def cut_rect(image):
    image = image
    rect = image.get_rect()
    size = (rect.w, rect.h)
    surf = pygame.Surface(size)
    height = 0
    width = 0
    space_left = 0
    space_top = 0
    
    for row in range(0, size[1]):
        row_surf = pygame.Surface((size[0], 1))
        row_surf.set_colorkey((0,0,0))
        row_surf.blit(image, (0, 0), (0, row, size[0], 1))
        row_mask = pygame.mask.from_surface(row_surf)
        row_pixels = row_mask.count()
        if row_pixels != 0:
            height += 1
        if height == 0:
            space_top += 1
    
    for col in range(0, size[0]):
        col_surf = pygame.Surface((1, size[1]))
        col_surf.set_colorkey((0,0,0))
        col_surf.blit(image, (0, 0), (col, 0, 1, size[1]))
        col_mask = pygame.mask.from_surface(col_surf)
        col_pixels = col_mask.count()
        if col_pixels != 0:
            width += 1
        if width == 0:
            space_left += 1
    
    return pygame.Rect(space_left, space_top, width, height)
        
        