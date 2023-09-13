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

type Figure* = ref object
    geom: Geometry
    pos*: Vector
    angle*: float32
    scale*: float32
    color*: Color
    radius: float32
    xcopy: int
    ycopy: int
    wrap: bool

func newFigure*(geometry: Geometry, scale: float32 = 1.0, wrap: bool = true): Figure =
    return Figure(
        geom: geometry,
        pos: Vector(x: 0, y: 0),
        angle: 0,
        scale: scale,
        color: Color(r: 200, g: 200, b: 200, a: 255),
        radius: geometry.radius*scale,
        xcopy: 0,
        ycopy: 0,
        wrap: wrap
    )

iterator points(self: Figure, offset: Vector): Vector =
    for point in self.geom.points:
        yield point.rotate(self.angle)*self.scale+self.pos+offset

iterator copies(self: Figure, ren: Renderer): Vector =
    yield Vector(x: 0, y: 0)
    if self.wrap:
        if self.xcopy != 0:
            yield Vector(x: self.xcopy.float32*ren.bounds.x*2, y: 0)
            if self.ycopy != 0:
                yield Vector(x: self.xcopy.float32*ren.bounds.x*2, y: self.ycopy.float32*ren.bounds.y*2)
        if self.ycopy != 0:
            yield Vector(x: 0, y: self.ycopy.float32*ren.bounds.y*2)

proc draw*(self: Figure, ren: Renderer) =
    if self.wrap:
        for offset in self.copies(ren):
            ren.newLine()
            for point in self.points(offset):
                ren.addPoint(point, self.color)
    else:
        ren.newLine()
        for point in self.points(Vector(x: 0, y: 0)):
            ren.addPoint(point, self.color)

proc move*(self: Figure, offset: Vector, ren: Renderer) =
    self.pos = self.pos+offset
    if self.wrap:
        if self.pos.x > ren.bounds.x: self.pos.x-=ren.bounds.x*2
        if self.pos.x < -ren.bounds.x: self.pos.x+=ren.bounds.x*2
        if self.pos.y > ren.bounds.y: self.pos.y-=ren.bounds.y*2
        if self.pos.y < -ren.bounds.y: self.pos.y+=ren.bounds.y*2

        if self.pos.x+self.radius+ren.thickness > ren.bounds.x:
            self.xcopy = -1
        elif self.pos.x-self.radius-ren.thickness < -ren.bounds.x:
            self.xcopy = 1
        else:
            self.xcopy = 0
        if self.pos.y+self.radius+ren.thickness > ren.bounds.y:
            self.ycopy = -1
        elif self.pos.y-self.radius-ren.thickness < -ren.bounds.y:
            self.ycopy = 1
        else:
            self.ycopy = 0


proc checkSingleCollision(fig1: Figure, fig1offset: Vector, fig2: Figure, fig2offset: Vector): bool =
    # Simple distance checking
    let distance = ((fig1.pos+fig1offset)-(fig2.pos+fig2offset)).len
    if distance > (fig1.radius+fig2.radius):
        return false

    # Using "http://content.gpwiki.org/index.php/Polygon_Collision"
    # (http://web.archive.org/web/20141127210836/http://content.gpwiki.org/index.php/Polygon_Collision)
    # Assuming both figures are convex polygons
    let points1 = fig1.points(fig1offset).toSeq
    let points2 = fig2.points(fig2offset).toSeq

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

proc checkCollision*(fig1: Figure, fig2: Figure, ren: Renderer): bool =
    for fig1offset in fig1.copies(ren):
        for fig2offset in fig2.copies(ren):
            if checkSingleCollision(fig1, fig1offset, fig2, fig2offset):
                return true
    return false
