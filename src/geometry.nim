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

func toUnit*(vec: Vector): Vector =
    let length = sqrt(vec.x*vec.x+vec.y*vec.y)
    return Vector(x: vec.x/length, y: vec.y/length)
