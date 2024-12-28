import display/[vectors, renderer]
import std/sequtils

type Geometry = object
    points: seq[Vector]
    radius*: float

func newGeometry*(points: openArray[Vector], closed: bool = true): Geometry {.compileTime.} =
    var maxRadius: float32 = 0
    for point in points.items:
        let radius = point.len
        if radius > maxRadius:
            maxRadius = radius
    var pointseq = @points
    if closed: pointseq.add points[0]
    return Geometry(points: pointseq, radius: maxRadius)

type Transform* = ref object
    pos*: Vector
    angle*: float32
    scale*: float32

type Figure* = ref object of RootObj
    geom*: Geometry
    transform*: Transform
    color*: Color
    renderer: Renderer
    radius*: float32

type WrapFigure* = ref object of Figure
    xcopy*: int
    ycopy*: int

type VectorIterator = iterator(): Vector

# TRANSFORM

func apply*(self: Transform, point: Vector): Vector = point.rotate(self.angle)*self.scale+self.pos

func move(self: Transform, offset: Vector) =
    self.pos = self.pos + offset

func rotate*(self: Transform, rotation: float32) =
    self.angle+=rotation


# FIGURE

method init*(self: Figure, ren: Renderer, geometry: Geometry, scale: float32 = 1.0) {.base.} =
    self.renderer = ren
    self.geom = geometry
    self.transform = Transform(
        pos: Vector(x: 0, y: 0),
        angle: 0,
        scale: scale
    )
    self.color = Color(r: 200, g: 200, b: 200, a: 255)
    self.radius = geometry.radius*scale


iterator points(self: Figure, offset: Vector): Vector =
    for point in self.geom.points:
        yield self.transform.apply(point)+offset


method copies(self: Figure): VectorIterator {.base.} =
    return iterator (): Vector =
        yield Vector(x: 0, y: 0)


method draw*(self: Figure) {.base.} =
    self.renderer.newLine()
    for point in self.points(Vector(x: 0, y: 0)):
        self.renderer.addPoint(point, self.color)

method move*(self: Figure, offset: Vector) {.base.} =
    self.transform.move(offset)

# WRAP FIGURE

method init*(self: WrapFigure, ren: Renderer, geometry: Geometry, scale: float32 = 1.0) =
    procCall self.Figure.init(ren, geometry, scale)
    self.xcopy = 0
    self.ycopy = 0


method copies(self: WrapFigure): VectorIterator =
    return iterator (): Vector =
        yield Vector(x: 0, y: 0)
        if self.xcopy != 0:
            yield Vector(x: self.xcopy.float32*self.renderer.bounds.x*2, y: 0)
            if self.ycopy != 0:
                yield Vector(
                    x: self.xcopy.float32*self.renderer.bounds.x*2,
                    y: self.ycopy.float32*self.renderer.bounds.y*2
                    )
        if self.ycopy != 0:
            yield Vector(x: 0, y: self.ycopy.float32*self.renderer.bounds.y*2)


method draw*(self: WrapFigure) =
    for offset in self.copies:
        self.renderer.newLine()
        for point in self.points(offset):
            self.renderer.addPoint(point, self.color)

method move*(self: WrapFigure, offset: Vector) =
    self.transform.move(offset)
    if self.transform.pos.x > self.renderer.bounds.x: self.transform.pos.x-=self.renderer.bounds.x*2
    if self.transform.pos.x < -self.renderer.bounds.x: self.transform.pos.x+=self.renderer.bounds.x*2
    if self.transform.pos.y > self.renderer.bounds.y: self.transform.pos.y-=self.renderer.bounds.y*2
    if self.transform.pos.y < -self.renderer.bounds.y: self.transform.pos.y+=self.renderer.bounds.y*2

    if self.transform.pos.x+self.radius+self.renderer.thickness > self.renderer.bounds.x:
        self.xcopy = -1
    elif self.transform.pos.x-self.radius-self.renderer.thickness < -self.renderer.bounds.x:
        self.xcopy = 1
    else:
        self.xcopy = 0

    if self.transform.pos.y+self.radius+self.renderer.thickness > self.renderer.bounds.y:
        self.ycopy = -1
    elif self.transform.pos.y-self.radius-self.renderer.thickness < -self.renderer.bounds.y:
        self.ycopy = 1
    else:
        self.ycopy = 0

# COMMON

proc checkSingleCollision(fig1: Figure, fig1offset: Vector, fig2: Figure, fig2offset: Vector): bool =
    # Simple distance checking
    let distance = ((fig1.transform.pos+fig1offset)-(fig2.transform.pos+fig2offset)).len
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


proc checkCollision*(fig1: Figure, fig2: Figure): bool =
    for fig1offset in fig1.copies:
        for fig2offset in fig2.copies:
            if checkSingleCollision(fig1, fig1offset, fig2, fig2offset):
                return true
    return false
