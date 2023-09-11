import display/window
import display/renderer
import geometry

const test = newGeometry(@[Vector(x: 1.0, y: 1.0), Vector(x: 0.5, y: -0.5)])
echo test

type GameWindow = ref object of AppWindow
    dummy: int

method onLoad(wnd: GameWindow) =
    discard

method onUpdate(wnd: GameWindow) =
    discard

method onDraw(wnd: GameWindow) =
    var col = Color(r: 200, g: 128, b: 100, a: 255)
    wnd.renderer.beginDraw(RenderType.Lines)
    wnd.renderer.addPoint(Vector(x: -0.5, y: -0.5), col)
    wnd.renderer.addPoint(Vector(x: 0.5, y: -0.5), col)
    wnd.renderer.addPoint(Vector(x: 0.5, y: 0.5), col)
    wnd.renderer.addPoint(Vector(x: -0.5, y: 0.5), col)
    wnd.renderer.newLine()
    wnd.renderer.addPoint(Vector(x: -0.5, y: -0.25), col)
    wnd.renderer.addPoint(Vector(x: -0.5, y: 0.25), col)
    wnd.renderer.endDraw()


let game = GameWindow()
game.init()
game.run()
