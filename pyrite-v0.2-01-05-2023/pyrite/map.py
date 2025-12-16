import pygame, os, math
from csv import reader
from .assets.sprite import Sprite
from .assets.json_loader import JsonLoader
from .assets.rect_cutter import cut_rect
from .assets.animation_loader import Animation

class CsvMap():
    def __init__(self, tile_size, wn_size, map_path, sprite_path):
        self.tarrain = str(map_path)
        self.tile_size = tile_size
        self.sprite = Sprite(pygame.image.load(str(sprite_path)), (16, 16), (self.tile_size, self.tile_size))
        self.sprite_rows, self.sprite_col = 7, 7
        self.surface = pygame.Surface((1920 * 3, 1080 * 3))
        self.surface.set_colorkey((0,0,0))
        self.wn_size = wn_size
        
        self.images = []
        
    def load_csv_data(self):
        """loads the map from csv file"""
        self.rows = 0
        self.colums = 0
        self.map_list = []
        with open (self.tarrain) as map:
            level = reader(map, delimiter = ",")
            for row in level:
                self.map_list.append(list(row))
            
    def load_images(self):
        """loads the tile images and saves them in an array"""
        for i in range(0, self.sprite_rows):
            for j in range(0, self.sprite_col):
                self.images.append(self.sprite.cut(j, i))
    
    def load(self):
        self.load_csv_data()
        self.load_images()
    
    def draw_map(self, scroll):
        """draws the map once on a reusable surface"""
        self.tile_list = []
        player_spawn = (0, 0)
        enemy_spawn = (0, 0)
        y = 0
        for row in self.map_list:
                self.colums = 0
                self.rows += 1
                y += self.tile_size
                x = 0
                for tile in row:
                    x += self.tile_size
                    self.colums += 1
                    if tile != '-1' and tile != '39' and tile != '40':
                            self.surface.blit(self.images[int(tile)], (x - scroll[0], y - scroll[1]))
                            img = self.images[int(tile)]
                            img_rect = img.get_rect()
                            img_rect.x, img_rect.y = x, y
                            self.tile_list.append([img, img_rect])
                    if tile == '39':
                        player_spawn = (x, y - 30)
                    if tile == '40':
                        enemy_spawn = (x, y - 30)
        
        return [self.surface, self.tile_list, player_spawn, enemy_spawn]
    
class MapAnimation:
    def __init__(self, animation_rules, sprite, tile_size, pos):
        for i in reversed(animation_rules):
            animation_type = i
        self.animation = Animation()
        self.animation.get_animation(sprite, animation_rules, (tile_size, tile_size), (tile_size, tile_size))
        self.animation.set_animation(animation_type)
        self.image = None
        self.update()
        self.rect = cut_rect(self.image)
        self.rect.x, self.rect.y = pos[0] + self.rect.x, pos[1] + self.rect.y
    
    def update(self):
        self.animation.update(self)
        

class LDTKMap:
    def __init__(self, folder_path, wn_size):
        self.folder_path = folder_path
        self.wn_size = wn_size
        
        self.json_loader = JsonLoader()
        self.map_info = self.json_loader.read_path(folder_path + '/map_info.json')
        self.map = self.json_loader.read_path(folder_path + '/' + self.map_info['map_path'])
        self.animation_rules = self.json_loader.read_path(folder_path + '/animation.json')
        self.collision_objects = []
        self.map_surf = None
        
    def load_map(self):
        self.map_w = self.map['levels'][0]['pxWid']
        self.map_h = self.map['levels'][0]['pxHei']
        self.map_size = (self.map_w, self.map_h)
        
    def create_animated_layer(self, layer, tileset, tile_size, layer_name, pos):
        aniamtion_rules = self.animation_rules['animations'][layer_name.lower()]

        return MapAnimation(aniamtion_rules, tileset, tile_size, pos)
    
    def update(self, scroll):
        temp_surf = pygame.Surface(self.map_size)
        temp_surf.fill((0, 0, 0))
        temp_surf.blit(self.surface, (0, 0))
        temp_surf.set_colorkey((0, 0, 0))
        for tile in self.tiles['animated_collision_tiles']:
            tile.update()
            temp_surf.blit(tile.image, (tile.rect.x, tile.rect.y))
        for tile in self.tiles['animated_tiles']:
            tile.update()
            temp_surf.blit(tile.image, (tile.rect.x, tile.rect.y))
        self.map_surf = temp_surf
        return self.map_surf
    
    def sort_layer(self, layer):
        properties = {'animated': False, 'collision': True}
        layer_name = layer.lower()
        if 'static' in layer_name:
            layer_name = layer_name.replace('_static', '')
            properties['animated'] = False
        if 'animated' in layer_name:
            layer_name = layer_name.replace('_animated', '')
            properties['animated'] = True
        if 'collision' in layer_name:
            layer_name = layer_name.replace('_collision', '')
            properties['collision'] = True
        return {'layer_name': layer_name, 'properties': properties}
        
    def draw_map(self, scroll):
        self.surface = pygame.Surface(self.map_size)
        self.surface.set_colorkey((0,0,0))
        self.layers = self.map['levels'][0]['layerInstances']
        self.tiles = {
            'collision_tiles': [],
            'animated_collision_tiles': [],
            'animated_tiles': [],
            'static_tiles': [],
            'collision_tile_list': []
        }
        
        for layer in self.layers:
            tileset_path = layer['__tilesetRelPath']
            tileset = pygame.image.load(self.folder_path + '/' + tileset_path)
            tile_size = layer['__gridSize']
            sprite = Sprite(tileset, (tile_size, tile_size), (tile_size, tile_size))
            grid_tiles = layer['gridTiles']
            layer_type = layer['__identifier']
            sorted_layer = self.sort_layer(layer_type)
            layer_name = sorted_layer['layer_name']
            properties = sorted_layer['properties']
            
            if properties['animated']:
                for gridTile in grid_tiles:
                    t_x, t_y = gridTile['px'][0], gridTile['px'][1]
                    if properties['collision']:
                        self.tiles['animated_collision_tiles'].append(self.create_animated_layer(layer, tileset, tile_size, layer_name, (t_x, t_y)))
                    else:
                        self.tiles['animated_tiles'].append(self.create_animated_layer(layer, tileset, tile_size, layer_name, (t_x, t_y)))
                
            if not properties['animated']:
                for gridTile in grid_tiles:
                    x, y = gridTile['px'][0], gridTile['px'][1]
                    t_x, t_y = gridTile['src'][0], gridTile['src'][1]
                    frame, layer = t_x / tile_size, t_y / tile_size
                    image = sprite.cut(frame, layer)
                    self.surface.blit(image, (x - scroll[0], y - scroll[1]))
                    rect = cut_rect(image)
                    rect.x, rect.y = x + rect.x, y + rect.y
                    if properties['collision']:
                        self.tiles['collision_tiles'].append([image, rect])
                    else:
                        self.tiles['static_tiles'].append([image, rect])
        
        collision_tile_list = []
        for c_tile in self.tiles['animated_collision_tiles']:
            collision_tile_list.append([c_tile.image, c_tile.rect])
        for tile in self.tiles['collision_tiles']:
            collision_tile_list.append([tile[0], tile[1]])
        self.tiles['collision_tile_list'] = collision_tile_list
                    
        return [self.surface, self.tiles, [100, 100], [100, 100], collision_tile_list]
        
                
    def load(self):
        self.load_map()
        
        
        