import display/window
import display/renderer
import display/vectors
import geometry

type GameWindow = ref object of AppWindow
    x: float32
    ship: Figure
    speed: float32

method onLoad(self: GameWindow) =
    self.ship = newFigure(geoShip)
    self.ship.scale = 0.1
    self.speed = 0.01

method onUpdate(self: GameWindow) =
    var direction = Vector(x: 0, y: 0)
    if self.isKeyPressed(KeyRight):
        self.ship.angle-=0.05
    if self.isKeyPressed(KeyLeft):
        self.ship.angle+=0.05
    if self.isKeyPressed(KeyUp):
        direction.y+=1
    if self.isKeyPressed(KeyDown):
        direction.y-=1
    if not direction.isZero:
        self.ship.pos = self.ship.pos+direction.toUnit.rotate(self.ship.angle)*self.speed

method onDraw(self: GameWindow) =
    var col = Color(r: 200, g: 128, b: 100, a: 255)
    self.renderer.beginDraw(RenderType.Lines)
    self.renderer.addPoint(Vector(x: -0.5+self.x, y: -0.5), col)
    self.renderer.addPoint(Vector(x: 0.5, y: -0.5), col)
    self.renderer.addPoint(Vector(x: 0.5, y: 0.5), col)
    self.renderer.addPoint(Vector(x: -0.5, y: 0.5), col)
    self.renderer.newLine()
    self.renderer.addPoint(Vector(x: -0.5, y: -0.25), col)
    self.renderer.addPoint(Vector(x: -0.5, y: 0.25), col)

    self.ship.draw(self.renderer)

    self.renderer.endDraw()


let game = GameWindow()
game.init()
game.run()
