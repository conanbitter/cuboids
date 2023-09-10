import staticglfw
import opengl
import display
import geometry

const test = newGeometry(@[Vector(x: 1.0, y: 1.0), Vector(x: 0.5, y: -0.5)])
echo test

if init() == 0:
    raise newException(Exception, "Failed to Initialize GLFW")

windowHint(CONTEXT_VERSION_MAJOR, 3)
windowHint(CONTEXT_VERSION_MINOR, 2)
windowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
windowHint(RESIZABLE, FALSE)

var window = createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
window.makeContextCurrent()
loadExtensions()

initRenderer()

while windowShouldClose(window) == 0:

    glClearColor(0.1, 0.1, 0.1, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
    showRenderer()

    window.swapBuffers()

    pollEvents()
    if window.getKey(KEY_ESCAPE) == 1:
        window.setWindowShouldClose(1)

freeRenderer()
window.destroyWindow()
terminate()
