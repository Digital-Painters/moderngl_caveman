"""
Perlin noise generator
"""

#Libs
import moderngl
import moderngl_window as mglw

#-------------------------------#

#Window App
class App(mglw.WindowConfig):

    #Set basic class variables
    window_size  = 1600, 900 
    resource_dir = 'programs'

    #Constructor
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        #Create context to render to
        self.quad = mglw.geometry.quad_fs()

        #Load and compile shaders
        self.prog = self.load_program(  vertex_shader   = 'perlin_vertex_shader.glsl',
                                        fragment_shader = 'perlin_fragment_shader.glsl')

        # Set basic shader program variables 
        # (look for uniform variables in the shader source code)
        self.set_uniform('resolution', self.window_size)

    def set_uniform(self,u_name, u_value):
        try:
            self.prog[u_name] = u_value
        except KeyError:
            print("failed to set variable {}".format(u_name))

    def render(self, time, frame_time):
        self.ctx.clear()
        self.set_uniform('time',time)
        self.quad.render(self.prog)


if __name__ == '__main__':
    mglw.run_window_config(App)