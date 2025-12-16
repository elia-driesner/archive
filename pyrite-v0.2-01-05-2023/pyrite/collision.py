import pygame

def tile_collision(rect, tiles):
    collision_list = []
    for tile in tiles:
        if isinstance(tile, list):
            if rect.colliderect(tile[1]):
                collision_list.append(tile)
    return collision_list

def move(entity, x_movement, y_movement, tile_list):
    entity = entity
    
    entity.rect.x += x_movement
    collisions = tile_collision(entity.rect, tile_list['collision_tile_list'])
    for tile in collisions:
        if x_movement > 0: # moving right, hit from left
            entity.rect.right = tile[1].left
            entity.velocity.x = 0
        if x_movement < 0: # moving left, hit from right
            entity.rect.left = tile[1].right
            entity.velocity.x = 0
    
    entity.rect.y += y_movement
    collisions = tile_collision(entity.rect, tile_list['collision_tile_list'])
    for tile in collisions:
        if y_movement > 0: # falling, hit from top
            entity.rect.bottom = tile[1].top
            entity.on_ground = True
        if y_movement < 0: # jumping, hit from botom
            entity.rect.top = tile[1].bottom
            entity.velocity.y = 0
    
    entity.update_position()