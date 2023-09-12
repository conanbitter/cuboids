import std/math
import std/strformat
import std/fenv

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

func isZero*(vec: Vector): bool =
    return vec.x.abs < float32.epsilon and vec.y.abs < float32.epsilon

func rotate*(vec: Vector, angle: float32): Vector =
    return Vector(
        x: vec.x*cos(angle)-vec.y*sin(angle),
        y: vec.x*sin(angle)+vec.y*cos(angle),
    )

func pseudoCross*(vec: Vector, other: Vector): float32 =
    vec.x * other.y - vec.y * other.x
