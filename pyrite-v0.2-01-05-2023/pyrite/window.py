import pygame, moderngl
from array import array
from .assets.customfont import CustomFont

def assign_window(game, config):
    if not config['use-gpu']:
        return Window(game, config)
    else:
        return ModernGLWindow(game, config)

class Window:
    def __init__(self, game, config):
        self.game = game

        self.wn_size = config['wn-size']
        self.wn_scale = config['wn-scale']
        self.fullscreen = config['fullscreen']
        self.bg_color = config['bg-color']
        self.show_fps = config['show-fps']
        self.render_offset = (0, 0)
        
        self.font = CustomFont(self.game.settings['font'])
        
        self.display = pygame.Surface(self.wn_size)
        if self.fullscreen:
            self.window = pygame.display.set_mode(self.wn_scale, pygame.FULLSCREEN)
        else:
            self.window = pygame.display.set_mode(self.wn_scale)
        pygame.display.set_caption(config['title'])
    
    def reset(self):
        self.display.fill(self.bg_color)
        
    def update(self):
        if self.show_fps:
            self.display.blit(self.font.write(f'FPS: {self.game.clock.fps}', 1), (5, 5))
        self.window.blit(pygame.transform.scale(self.display, self.wn_scale), self.render_offset)
        pygame.display.update()
        
class ModernGLWindow:
    def __init__(self, game, config):
        self.wn_size = config['wn-size']
        self.wn_scale = config['wn-scale']
        self.fullscreen = config['fullscreen']
        self.bg_color = config['bg-color']
        self.show_fps = config['show-fps']
        self.render_offset = (0, 0)
        
        pygame.display.gl_set_attribute(pygame.GL_CONTEXT_MAJOR_VERSION, 3)
        pygame.display.gl_set_attribute(pygame.GL_CONTEXT_MINOR_VERSION, 3)
        pygame.display.gl_set_attribute(pygame.GL_CONTEXT_PROFILE_MASK, pygame.GL_CONTEXT_PROFILE_CORE)
        pygame.display.gl_set_attribute(pygame.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG, True)
        
        if self.fullscreen:
            self.window = pygame.display.set_mode(self.wn_scale, pygame.OPENGL | pygame.DOUBLEBUF | pygame.FULLSCREEN)
        else:
            self.window = pygame.display.set_mode(self.wn_scale, pygame.OPENGL | pygame.DOUBLEBUF)
            
        self.ctx = moderngl.create_context()
        
        quad_buffer = self.ctx.buffer(data=array('f', [
        # position (x, y), uv coords (x, y)
        -1.0, 1.0, 0.0, 0.0,  # topleft
        1.0, 1.0, 1.0, 0.0,   # topright
        -1.0, -1.0, 0.0, 1.0, # bottomleft
        1.0, -1.0, 1.0, 1.0,  # bottomright
        ]))
        
        vert_shader = '''
        #version 330 core

        in vec2 vert;
        in vec2 texcoord;
        out vec2 uvs;

        void main() {
            uvs = texcoord;
            gl_Position = vec4(vert, 0.0, 1.0);
        }
        '''

        frag_shader = '''
        #version 330 core

        uniform sampler2D tex;

        in vec2 uvs;
        out vec4 f_color;

        void main() {
            f_color = vec4(texture(tex, uvs).r, texture(tex, uvs).g, texture(tex, uvs).b, 1.0);
        }
        '''
        
        self.program = self.ctx.program(vertex_shader=vert_shader, fragment_shader=frag_shader)
        self.render_object = self.ctx.vertex_array(self.program, [(quad_buffer, '2f 2f', 'vert', 'texcoord')])
        
        self.game = game
        
        self.font = CustomFont(self.game.settings['font'])
        
        self.display = pygame.Surface(self.wn_size)
        pygame.display.set_caption(config['title'])
    
    def surf_to_texture(self, surf):
        tex = self.ctx.texture(surf.get_size(), 4)
        tex.filter = (moderngl.NEAREST, moderngl.NEAREST)
        tex.swizzle = 'BGRA'
        tex.write(surf.get_view('1'))
        return tex
    
    def reset(self):
        self.display.fill(self.bg_color)
        
    def update(self):
        if self.show_fps:
            self.display.blit(self.font.write(f'FPS: {self.game.clock.fps}', 1), (5, 5))
        
        frame_tex = self.surf_to_texture(pygame.transform.scale(self.display, self.wn_scale))
        frame_tex.use(0)
        self.program['tex'] = 0
        self.render_object.render(mode=moderngl.TRIANGLE_STRIP)
        
        # self.window.blit(pygame.transform.scale(self.display, self.wn_scale), self.render_offset)
        
        pygame.display.flip()
        frame_tex.release()