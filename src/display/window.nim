import staticglfw
import renderer
import std/tables

type KeyCode* = enum
    KeyLeft, KeyRight, KeyUp, KeyDown, KeyAction

const keyTable = {
    KeyLeft: staticglfw.KEY_LEFT,
    KeyRight: staticglfw.KEY_RIGHT,
    KeyUp: staticglfw.KEY_UP,
    KeyDown: staticglfw.KEY_DOWN,
    KeyAction: staticglfw.KEY_Z
}.toTable()

type AppWindow* = ref object of RootObj
    window: Window
    renderer*: Renderer

method onLoad*(wnd: AppWindow){.base.} =
    discard

method onUpdate*(wnd: AppWindow){.base.} =
    discard

method onDraw*(wnd: AppWindow){.base.} =
    discard

method onUnload*(wnd: AppWindow){.base.} =
    discard

proc sizeCallback(window: Window, width: cint, height: cint){.cdecl.} =
    let renderer = cast[ptr Renderer](window.getWindowUserPointer())[]
    renderer.setViewport(width, height)

proc init*(wnd: AppWindow) =
    if init() == 0:
        raise newException(Exception, "Failed to Initialize GLFW")

    windowHint(CONTEXT_VERSION_MAJOR, 3)
    windowHint(CONTEXT_VERSION_MINOR, 2)
    windowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)
    #windowHint(RESIZABLE, FALSE)

    var width = 800
    var height = 600

    wnd.window = createWindow((cint)width, (cint)height, "Cuboids", nil, nil)
    wnd.window.makeContextCurrent()

    wnd.renderer = newRenderer()
    wnd.renderer.setViewport(width, height)

    wnd.window.setWindowUserPointer(addr wnd.renderer)
    discard wnd.window.setWindowSizeCallback(sizeCallback)

proc isKeyPressed*(wnd: AppWindow, key: KeyCode): bool =
    return wnd.window.getKey(keyTable[key].cint) == 1

proc run*(wnd: AppWindow) =
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
