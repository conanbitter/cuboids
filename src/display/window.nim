import staticglfw
import renderer

type Window* = ref object
    window: staticglfw.Window
    renderer*: Renderer

proc newWindow*(): Window =
    if init() == 0:
        raise newException(Exception, "Failed to Initialize GLFW")

    windowHint(CONTEXT_VERSION_MAJOR, 3)
    windowHint(CONTEXT_VERSION_MINOR, 2)
    windowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
    windowHint(RESIZABLE, FALSE)

    result = Window()

    result.window = createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
    result.window.makeContextCurrent()

    result.renderer = newRenderer()

proc run*(wnd: Window) =
    while windowShouldClose(wnd.window) == 0:

        wnd.renderer.startRender()
        wnd.window.swapBuffers()

        pollEvents()
        if wnd.window.getKey(KEY_ESCAPE) == 1:
            wnd.window.setWindowShouldClose(1)

    wnd.renderer.free()
    wnd.window.destroyWindow()
    terminate()
