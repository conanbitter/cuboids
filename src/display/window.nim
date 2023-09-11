import staticglfw
import renderer

type Window* = ref object of RootObj
    window: staticglfw.Window
    renderer*: Renderer

method onLoad*(wnd: Window){.base.} =
    discard

method onUpdate*(wnd: Window){.base.} =
    discard

method onDraw*(wnd: Window){.base.} =
    discard

method onUnload*(wnd: Window){.base.} =
    discard

proc init*(wnd: Window) =
    if init() == 0:
        raise newException(Exception, "Failed to Initialize GLFW")

    windowHint(CONTEXT_VERSION_MAJOR, 3)
    windowHint(CONTEXT_VERSION_MINOR, 2)
    windowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
    windowHint(RESIZABLE, FALSE)

    wnd.window = createWindow(800, 600, "GLFW3 WINDOW", nil, nil)
    wnd.window.makeContextCurrent()

    wnd.renderer = newRenderer()


proc run*(wnd: Window) =
    wnd.onLoad()

    while windowShouldClose(wnd.window) == 0:
        pollEvents()
        if wnd.window.getKey(KEY_ESCAPE) == 1:
            wnd.window.setWindowShouldClose(1)
        wnd.onUpdate()

        wnd.renderer.startRender()
        wnd.onDraw()
        wnd.renderer.finishRender()
        wnd.window.swapBuffers()

    wnd.onUnload()
    wnd.renderer.free()
    wnd.window.destroyWindow()
    terminate()
