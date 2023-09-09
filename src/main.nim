import staticglfw
import opengl
import display/shaders

const vertexShaderCode = """
    #version 150

    in vec2 vert;
    in vec4 vertColor;

    out vec4 fragColor;

    void main() {
        gl_Position = vec4(vert.x, vert.y, 0.0, 1.0);
        fragColor = vertColor;
    }
"""

const fragmentShaderCode = """
    #version 150

    in vec4 fragColor;

    out vec4 outputColor;

    void main() {
        outputColor = fragColor;
    }
"""


if init() == 0:
    raise newException(Exception, "Failed to Initialize GLFW")

var window = createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
window.makeContextCurrent()
loadExtensions()

let shader = compileShaderProgram(vertexShaderCode, fragmentShaderCode)
echo shader

while windowShouldClose(window) == 0:

    glClearColor(0.1, 0.1, 0.1, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)

    window.swapBuffers()

    pollEvents()
    if window.getKey(KEY_ESCAPE) == 1:
        window.setWindowShouldClose(1)

window.destroyWindow()
terminate()
