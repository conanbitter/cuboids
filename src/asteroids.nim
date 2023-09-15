import geometry
import display/[vectors, renderer]
import constants

type Asteroid = ref object of Figure
    speed: Vector
    rotSpeed: float32
    level: int
    active: bool

type AsterManager* = ref object
    items: seq[Asteroid]

const childOffsets: seq[Vector] = @[
    Vector(x: -0.5, y: -0.5),
    Vector(x: -0.5, y: 0.5),
    Vector(x: 0.5, y: 0.5),
    Vector(x: 0.5, y: -0.5)
]

func update(self: Asteroid, ren: Renderer) =
    self.move(self.speed, ren)
    self.angle+=self.rotSpeed

func init*(self: AsterManager) =
    self.items.add Asteroid(
        geom: GEO_ASTER,
        pos: Vector(x: 0.5, y: 0),
        angle: 0,
        scale: ASTER_SCALE,
        color: Color(r: 200, g: 200, b: 200, a: 255),
        radius: GEO_ASTER.radius*ASTER_SCALE,
        xcopy: 0,
        ycopy: 0,
        wrap: true,
        speed: Vector(x: 0.001, y: 0.001),
        rotSpeed: 0.01,
        level: 1,
        active: true
    )

func update*(self: AsterManager, ren: Renderer) =
    for item in self.items:
        item.update(ren)

func draw*(self: AsterManager, ren: Renderer) =
    for item in self.items:
        if item.active:
            item.draw(ren)

proc checkShoot*(self: AsterManager, projectile: Figure, projSpeed: Vector, ren: Renderer): bool =
    for i in 0..<self.items.len:
        if not self.items[i].active:
            continue
        if checkCollision(projectile, self.items[i], ren):
            if self.items[i].level > 2:
                self.items[i].active = false
                return true
            var first = true
            let newScale = self.items[i].scale/2.0'f32
            let oldAster = self.items[i]
            for offset in childOffsets:
                let newAsteroid = Asteroid(
                    geom: GEO_ASTER,
                    pos: oldAster.pos+offset*oldAster.scale,
                    angle: oldAster.angle,
                    scale: newScale,
                    color: Color(r: 200, g: 200, b: 200, a: 255),
                    radius: GEO_ASTER.radius*newScale,
                    xcopy: 0,
                    ycopy: 0,
                    wrap: true,
                    speed: (oldAster.speed+offset*0.001+projSpeed).toUnit*0.001,
                    rotSpeed: oldAster.rotSpeed*1.1,
                    level: oldAster.level+1,
                    active: true
                )
                if first:
                    self.items[i] = newAsteroid
                    first = false
                else:
                    self.items.add newAsteroid
            return true
    return false
