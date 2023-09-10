import opengl
import ../geometry
import shaders

type Color* = object
    r: uint8
    g: uint8
    b: uint8
    a: uint8

type Vertex {.packed.} = object
    pos: Vector
    color: Color

type Renderer* = ref object
    program: GLuint
    vao: GLuint
    vbo: GLuint
    ar_loc: GLint


const vertexShaderCode = """
    #version 150

    uniform float ar;

    in vec2 vert;
    in vec4 vertColor;

    out vec4 fragColor;

    void main() {
        gl_Position = vec4(vert.x / ar, vert.y, 0.0, 1.0);
        fragColor = vertColor;
    }
"""

const fragmentShaderCode = """
    #version 150

    in vec4 fragColor;

    out vec4 outputColor;

    void main() {
        outputColor = fragColor;
    }
"""

var vertices: seq[Vertex] = @[
    Vertex(pos: Vector(x: -0.5, y: -0.5), color: Color(r: 255, g: 0, b: 0, a: 255)),
    Vertex(pos: Vector(x: 0.5, y: -0.5), color: Color(r: 0, g: 255, b: 0, a: 255)),
    Vertex(pos: Vector(x: -0.5, y: 0.5), color: Color(r: 0, g: 0, b: 255, a: 255)),
    Vertex(pos: Vector(x: 0.5, y: -0.5), color: Color(r: 0, g: 255, b: 0, a: 255)),
    Vertex(pos: Vector(x: 0.5, y: 0.5), color: Color(r: 255, g: 255, b: 255, a: 255)),
    Vertex(pos: Vector(x: -0.5, y: 0.5), color: Color(r: 0, g: 0, b: 255, a: 255)),
]


#proc addPoint(pos: Vector, color: Color) =
#    vertices.add(Vertex(pos: pos, color: color))

proc newRenderer*(): Renderer =
    result = Renderer()

    loadExtensions()
    # Set properties
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glEnable(GL_LINE_SMOOTH)
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST)
    glLineWidth(9.0)
    glPointSize(9.0)

    # Init shader
    result.program = compileShaderProgram(vertexShaderCode, fragmentShaderCode)
    glUseProgram(result.program)
    result.ar_loc = glGetUniformLocation(result.program, "ar")
    var vert_loc = glGetAttribLocation(result.program, "vert")
    var col_loc = glGetAttribLocation(result.program, "vertColor")

    # Init buffers
    glDisable(GL_BLEND)
    glDisable(GL_DEPTH_TEST)
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1)
    glGenVertexArrays(1, addr result.vao)
    glBindVertexArray(result.vao)
    glGenBuffers(1, addr result.vbo)
    glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
    glEnableVertexAttribArray((GLuint)vert_loc)
    glVertexAttribPointer((GLuint)vert_loc, 2, cGL_FLOAT, false, (GLsizei)Vertex.sizeof, nil)
    glEnableVertexAttribArray((GLuint)col_loc)
    glVertexAttribPointer((GLuint)col_loc, 4, GL_UNSIGNED_BYTE, true, (GLsizei)Vertex.sizeof,
        cast[pointer](float32.sizeof * 2))

    glUniform1f(result.ar_loc, 1.0)
    glBufferData(GL_ARRAY_BUFFER, vertices.len * Vertex.sizeof, addr vertices[0], GL_STATIC_DRAW)


proc free*(ren: Renderer) =
    if glIsBuffer(ren.vbo):
        glDeleteBuffers(1, addr ren.vbo)

    if glIsVertexArray(ren.vao):
        glDeleteVertexArrays(1, addr ren.vao)

    if glIsProgram(ren.program):
        glDeleteProgram(ren.program)

proc startRender*(ren: Renderer) =
    glClearColor(0.1, 0.1, 0.1, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
    glUseProgram(ren.program)
    glBindVertexArray(ren.vao)
    glDrawArrays(GL_LINES, 0, 6)
