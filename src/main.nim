import staticglfw
import opengl

if init() == 0:
    raise newException(Exception, "Failed to Initialize GLFW")

var window = createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
window.makeContextCurrent()
loadExtensions()

while windowShouldClose(window) == 0:

    glClearColor(0.1, 0.1, 0.1, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)

    window.swapBuffers()

    pollEvents()
    if window.getKey(KEY_ESCAPE) == 1:
        window.setWindowShouldClose(1)

window.destroyWindow()
terminate()
