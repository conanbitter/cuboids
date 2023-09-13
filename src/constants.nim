import display/vectors
import geometry

const GEO_SHIP* = newGeometry(@[
    Vector(x: 0.0, y: 1.2),
    Vector(x: 0.7, y: -0.8),
    Vector(x: -0.7, y: -0.8),
], closed = true)

const GEO_ASTER* = newGeometry(@[
    Vector(x: -1.0, y: -1.0),
    Vector(x: -1.0, y: 1.0),
    Vector(x: 1.0, y: 1.0),
    Vector(x: 1.0, y: -1.0),
], closed = true)

const GEO_PROJ* = newGeometry(@[
    Vector(x: 0.0, y: 0.8),
    Vector(x: 0.2, y: 0.0),
    Vector(x: 0.0, y: -1.2),
    Vector(x: -0.2, y: 0.0),
], closed = true)

const SHIP_SCALE* = 0.1'f32
const SHIP_MAX_SPEED* = 0.1'f32
const SHIP_ACCELERATION* = 0.001'f32
const SHIP_DRAG* = 0.0001'f32
const SHIP_ROT_SPEED* = 0.05'f32

const ASTER_SCALE* = 0.2'f32

const PROJ_SCALE* = 0.05'f32
const PROJ_SPEED* = 0.01'f32
