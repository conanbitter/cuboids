import display/window
import display/renderer
import display/vectors
import geometry

type GameWindow = ref object of AppWindow
    x: float32
    ship: Figure
    cube: Figure
    shipSpeed: Vector
    speed: float32
    active: bool

const SHIP_MAX_SPEED = 0.1'f32
const SHIP_ACCELERATION = 0.001'f32
const SHIP_DRAG = 0.0001'f32

method onLoad(self: GameWindow) =
    self.ship = newFigure(self.renderer, geoShip, 0.1)
    self.shipSpeed = Vector(x: 0, y: 0)
    self.cube = newFigure(self.renderer, geoSquare, 0.2)
    self.cube.pos = Vector(x: 0.5, y: 0)
    self.active = true

method onUpdate(self: GameWindow) =
    #[var thrust = Vector(x: 0, y: 0)
    if self.isKeyPressed(KeyRight):
        self.ship.angle-=0.05
    if self.isKeyPressed(KeyLeft):
        self.ship.angle+=0.05
    if self.isKeyPressed(KeyUp):
        thrust.y+=1
    if self.isKeyPressed(KeyDown):
        thrust.y-=1
    if not thrust.isZero:
        self.shipSpeed = self.shipSpeed+thrust.toUnit.rotate(self.ship.angle)*SHIP_ACCELERATION
    if self.shipSpeed.len > SHIP_MAX_SPEED:
        self.shipSpeed = self.shipSpeed.toUnit*SHIP_MAX_SPEED
    if self.shipSpeed.len < SHIP_DRAG:
        self.shipSpeed = Vector(x: 0, y: 0)
    else:
        self.shipSpeed = self.shipSpeed.toUnit*(self.shipSpeed.len-SHIP_DRAG)
    self.ship.pos = self.ship.pos+self.shipSpeed]#
    if self.isKeyPressed(KeyC):
        self.active = not self.active
    let active = if self.active: self.ship else: self.cube
    var offset: Vector
    if self.isKeyPressed(KeyRight):
        offset.x+=0.01
    if self.isKeyPressed(KeyLeft):
        offset.x-=0.01
    if self.isKeyPressed(KeyUp):
        offset.y+=0.01
    if self.isKeyPressed(KeyDown):
        offset.y-=0.01
    if not offset.isZero:
        active.updatePos(offset, self.renderer)
    if self.isKeyPressed(KeyA):
        active.angle+=0.05
    if self.isKeyPressed(KeyB):
        active.angle-=0.05

method onDraw(self: GameWindow) =
    self.renderer.beginDraw(RenderType.Lines)

    let c1 = Color(r: 200, g: 50, b: 50, a: 255)
    let c2 = Color(r: 50, g: 200, b: 50, a: 255)
    if checkCollision(self.ship, self.cube, self.renderer):
        self.ship.color = c1
    else:
        self.ship.color = c2
    self.ship.draw(self.renderer)
    self.cube.draw(self.renderer)

    self.renderer.endDraw()


let game = GameWindow()
game.init()
game.run()
