import pygame
from .sprite import Sprite

class CustomFont:
    def __init__(self, config):
        self.image_path = config['img-path']
        self.sprite = Sprite(pygame.image.load(self.image_path), (8, 11), (8, 11))
        self.alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
        self.characters = []
        self.char_surf = pygame.Surface(((100, 500)))
        self.char_surf.set_colorkey((0,0,0))
        self.load_font()
        
    def load_font(self):
        for i in range(0, 26):
            character = self.sprite.cut(i, 0)
            self.characters.append(character)
        for j in range(0, 10):
            self.number = self.sprite.cut(j, 1)
            self.characters.append(self.number)
            
    def write(self, text, font_size):
        text = str(text)
        size = 0
        for char in text:
            if char.lower() in self.alphabet or char.lower() == ' ':
                size += 8    
        placeholder_surf = pygame.Surface((size, 11)) 
        placeholder_surf.fill((0, 0, 0, 0))   
        x = 0
        for char in text:
            if char.lower() in self.alphabet or char.lower() == ' ':
                if char.lower() != ' ':        
                    index = self.alphabet.index(char.lower())
                    placeholder_surf.blit(self.characters[index], (x, 0))
                x += 8
        return pygame.transform.scale(placeholder_surf, (font_size * size, font_size * 11))