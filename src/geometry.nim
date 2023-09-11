import display/[vectors, renderer]

type Geometry = object
    points: seq[Vector]
    radius: float

func newGeometry*(points: openArray[Vector], closed: bool = true): Geometry {.compileTime.} =
    var maxRadius: float32 = 0
    for point in points.items:
        let radius = point.len
        if radius > maxRadius:
            maxRadius = radius
    var pointseq = @points
    if closed: pointseq.add points[0]
    return Geometry(points: pointseq, radius: maxRadius)

const geoSquare* = newGeometry(@[
    Vector(x: -1.0, y: -1.0),
    Vector(x: -1.0, y: 1.0),
    Vector(x: 1.0, y: 1.0),
    Vector(x: 1.0, y: -1.0),
], closed = true)

const geoShip* = newGeometry(@[
    Vector(x: 0.0, y: 1.2),
    Vector(x: 0.7, y: -0.8),
    Vector(x: -0.7, y: -0.8),
], closed = true)

type Figure* = ref object
    geom: Geometry
    pos*: Vector
    angle*: float32
    scale*: float32
    color*: Color

func newFigure*(geometry: Geometry): Figure =
    return Figure(
        geom: geometry,
        pos: Vector(x: 0, y: 0),
        angle: 0,
        scale: 1.0,
        color: Color(r: 200, g: 200, b: 200, a: 255)
    )

proc draw*(self: Figure, ren: Renderer) =
    ren.newLine()
    for point in self.geom.points:
        ren.addPoint(point.rotate(self.angle)*self.scale+self.pos, self.color)
