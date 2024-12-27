import geometry
import display/[vectors, renderer]
import constants

type Projectile = ref object of Figure
    speed: Vector

type ProjManager* = seq[Projectile]

func update*(self: Projectile) =
    self.move(self.speed)

proc remove*(self: var ProjManager, index: int) =
    self[index] = self[^1]
    self.setLen(self.len-1)

func update*(self: var ProjManager, ren: Renderer) =
    for ind, item in self.pairs:
        item.update()
        if item.transform.pos.x-item.radius-ren.thickness > ren.bounds.x or
            item.transform.pos.x+item.radius+ren.thickness < -ren.bounds.x or
            item.transform.pos.y-item.radius-ren.thickness > ren.bounds.y or
            item.transform.pos.y+item.radius+ren.thickness < -ren.bounds.y:
            self.remove(ind)

proc draw*(self: ProjManager) =
    for item in self:
        item.draw()

proc add*(self: var ProjManager, pos: Vector, angle: float32, ren: Renderer) =
    var newProj = new Projectile
    newProj.init(ren, GEO_PROJ, PROJ_SCALE)
    newProj.transform.pos = ren.wrapPoint(pos)
    newProj.transform.angle = angle
    self.add(newProj)
