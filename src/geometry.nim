import display/[vectors, renderer]
import std/sequtils

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

iterator points(self: Figure): Vector =
    for point in self.geom.points:
        yield point.rotate(self.angle)*self.scale+self.pos

proc draw*(self: Figure, ren: Renderer) =
    ren.newLine()
    for point in self.points:
        ren.addPoint(point, self.color)

proc checkCollision*(fig1, fig2: Figure): bool =
    # Simple distance checking
    let distance = (fig1.pos-fig2.pos).len
    if distance > (fig1.geom.radius*fig1.scale+fig2.geom.radius*fig2.scale):
        return false

    # Using "http://content.gpwiki.org/index.php/Polygon_Collision"
    # (http://web.archive.org/web/20141127210836/http://content.gpwiki.org/index.php/Polygon_Collision)
    # Assuming both figures are convex polygons
    let points1 = fig1.points.toSeq
    let points2 = fig2.points.toSeq

    for i in 0..points1.len-2:
        let v1 = points1[i+1]-points1[i]
        var outside = true
        for point in points2:
            let v2 = point-points1[i]
            if v1.pseudoCross(v2) < 0:
                outside = false
                break
        if outside:
            return false

    for i in 0..points2.len-2:
        let v1 = points2[i+1]-points2[i]
        var outside = true
        for point in points1:
            let v2 = point-points2[i]
            if v1.pseudoCross(v2) < 0:
                outside = false
                break
        if outside:
            return false

    return true
