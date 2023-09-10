import std/strformat
import std/math

type
    Vector* = object
        x*: float32
        y*: float32

func `$`*(vector: Vector): string =
    return fmt"[{vector.x:.3f}, {vector.y:.3f}]"

func `+`*(vec1, vec2: Vector): Vector =
    Vector(x: vec1.x+vec2.x, y: vec1.y+vec2.y)

func `-`*(vec1, vec2: Vector): Vector =
    Vector(x: vec1.x-vec2.x, y: vec1.y-vec2.y)

func `*`*(vec: Vector, multiplier: float32): Vector =
    Vector(x: vec.x*multiplier, y: vec.y*multiplier)

func `/`*(vec: Vector, denominator: float32): Vector =
    Vector(x: vec.x/denominator, y: vec.y/denominator)

func len*(vec: Vector): float32 = sqrt(vec.x*vec.x+vec.y*vec.y)

func toUnit*(vec: Vector): Vector =
    let length = vec.len
    return Vector(x: vec.x/length, y: vec.y/length)


type Geometry = object
    lines: seq[Vector]
    radius: float

func newGeometry*(points: openArray[Vector], closed: bool = true): Geometry {.compileTime.} =
    var maxRadius: float32 = 0
    for point in points.items:
        let radius = point.len
        if radius > maxRadius:
            maxRadius = radius
    var pointseq = @points
    if closed: pointseq.add points[0]
    return Geometry(lines: pointseq, radius: maxRadius)
