import display/window
import display/renderer
import display/vectors
import geometry
import constants
import asteroids

type GameWindow = ref object of AppWindow
    x: float32
    ship: Figure
    proj: Figure
    projActive: bool
    projDirection: Vector
    shipSpeed: Vector
    speed: float32
    asterMan: AsterManager

method onLoad(self: GameWindow) =
    self.ship = newFigure(GEO_SHIP, SHIP_SCALE)
    self.shipSpeed = Vector(x: 0, y: 0)
    self.proj = newFigure(GEO_PROJ, PROJ_SCALE, wrap = false)
    self.projActive = false
    self.asterMan = AsterManager()
    self.asterMan.init()

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
    self.asterMan.update(self.renderer)
    if self.isKeyPressed(KeyC) and not self.projActive:
        self.proj.angle = self.ship.angle
        self.proj.pos = self.renderer.wrapPoint(self.ship.pos+Vector(x: 0, y: self.ship.radius).rotate(self.ship.angle))
        self.projDirection = Vector(x: 0, y: PROJ_SPEED).rotate(self.ship.angle)
        self.projActive = true

    if self.projActive:
        self.proj.move(self.projDirection, self.renderer)
        if self.proj.pos.x-self.proj.radius-self.renderer.thickness > self.renderer.bounds.x or
            self.proj.pos.x+self.proj.radius+self.renderer.thickness < -self.renderer.bounds.x or
            self.proj.pos.y-self.proj.radius-self.renderer.thickness > self.renderer.bounds.y or
            self.proj.pos.y+self.proj.radius+self.renderer.thickness < -self.renderer.bounds.y:
            self.projActive = false
        if self.asterMan.checkShoot(self.proj, self.projDirection, self.renderer):
            self.projActive = false

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
        self.ship.move(offset, self.renderer)
    if self.isKeyPressed(KeyA):
        self.ship.angle+=SHIP_ROT_SPEED
    if self.isKeyPressed(KeyB):
        self.ship.angle-=SHIP_ROT_SPEED

method onDraw(self: GameWindow) =
    self.renderer.beginDraw(RenderType.Lines)

    self.asterMan.draw(self.renderer)
    self.ship.draw(self.renderer)
    if self.projActive:
        self.proj.draw(self.renderer)

    self.renderer.endDraw()


let game = GameWindow()
game.init()
game.run()
