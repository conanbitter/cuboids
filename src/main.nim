import display/window
import display/renderer
import display/vectors
import geometry
import constants
import asteroids

type GameWindow = ref object of AppWindow
    x: float32
    ship: WrapFigure
    proj: Figure
    projActive: bool
    projDirection: Vector
    shipSpeed: Vector
    speed: float32
    asterMan: AsterManager

method onLoad(self: GameWindow) =
    self.ship = WrapFigure()
    self.ship.init(self.renderer, GEO_SHIP, SHIP_SCALE)
    self.shipSpeed = Vector(x: 0, y: 0)
    self.proj = Figure()
    self.proj.init(self.renderer, GEO_PROJ, PROJ_SCALE)
    self.projActive = false
    self.asterMan.init(self.renderer)

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
    self.asterMan.update()
    if self.isKeyPressed(KeyC) and not self.projActive:
        self.proj.transform.angle = self.ship.transform.angle
        self.proj.transform.pos = self.renderer.wrapPoint(self.ship.transform.pos+Vector(x: 0,
                y: self.ship.radius).rotate(self.ship.transform.angle))
        self.projDirection = Vector(x: 0, y: PROJ_SPEED).rotate(self.ship.transform.angle)
        self.projActive = true

    #TODO fire at fixed time rate
    if self.projActive:
        self.proj.move(self.projDirection)
        if self.proj.transform.pos.x-self.proj.radius-self.renderer.thickness > self.renderer.bounds.x or
            self.proj.transform.pos.x+self.proj.radius+self.renderer.thickness < -self.renderer.bounds.x or
            self.proj.transform.pos.y-self.proj.radius-self.renderer.thickness > self.renderer.bounds.y or
            self.proj.transform.pos.y+self.proj.radius+self.renderer.thickness < -self.renderer.bounds.y:
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
        self.ship.move(offset)
    if self.isKeyPressed(KeyA):
        self.ship.transform.angle+=SHIP_ROT_SPEED
    if self.isKeyPressed(KeyB):
        self.ship.transform.angle-=SHIP_ROT_SPEED

method onDraw(self: GameWindow) =
    self.renderer.beginDraw(RenderType.Lines)

    self.asterMan.draw()
    self.ship.draw()
    if self.projActive:
        self.proj.draw()

    self.renderer.endDraw()


let game = GameWindow()
game.init()
game.run()
