import geometry
import display/[vectors, renderer]
import constants

type Asteroid = ref object of WrapFigure
    speed: Vector
    rotSpeed: float32
    level: int
    active: bool

type AsterManager* = seq[Asteroid]

const childOffsets: seq[Vector] = @[
    Vector(x: -0.5, y: -0.5),
    Vector(x: -0.5, y: 0.5),
    Vector(x: 0.5, y: 0.5),
    Vector(x: 0.5, y: -0.5)
]

func update(self: Asteroid) =
    if self.speed.len > 0.001: self.speed = self.speed*0.993
    self.move(self.speed)
    self.transform.rotate(self.rotSpeed)

func init*(self: var AsterManager, ren: Renderer) =
    var newAsteroid = Asteroid()
    newAsteroid.init(ren, GEO_ASTER, ASTER_SCALE)
    newAsteroid.transform.pos = Vector(x: 0.5, y: 0)
    newAsteroid.transform.angle = 0.1
    newAsteroid.speed = Vector(x: 0.001, y: 0.001)
    newAsteroid.rotSpeed = 0.01
    newAsteroid.level = 1
    newAsteroid.active = true
    self.add(newAsteroid)

func update*(self: AsterManager) =
    for item in self:
        item.update()

proc draw*(self: AsterManager) =
    for item in self:
        if item.active:
            item.draw()

proc checkShoot*(self: var AsterManager, projectile: Figure, projSpeed: Vector, ren: Renderer): bool =
    for i in 0..<self.len:
        if not self[i].active:
            continue
        if checkCollision(projectile, self[i]):
            if self[i].level > 2:
                self[i].active = false
                return true
            var first = true
            let newScale = self[i].transform.scale/2.0'f32
            let oldAster = self[i]
            for offset in childOffsets:
                let newAsteroid = Asteroid()
                newAsteroid.init(ren, GEO_ASTER, newScale)
                newAsteroid.transform.pos = oldAster.transform.apply(offset)
                newAsteroid.transform.angle = oldAster.transform.angle
                newAsteroid.speed = (oldAster.speed+offset*0.01+projSpeed*1.5).toUnit*0.005
                newAsteroid.rotSpeed = oldAster.rotSpeed*1.1
                newAsteroid.level = oldAster.level+1
                newAsteroid.active = true

                if first:
                    self[i] = newAsteroid
                    first = false
                else:
                    self.add newAsteroid
            return true
    return false
