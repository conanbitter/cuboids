import opengl
import geometry
import display/shaders

type Color = object
    r: uint8
    g: uint8
    b: uint8
    a: uint8

type Vertex {.packed.} = object
    pos: Vector
    color: Color

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

var program: Shader
var vertices: seq[Vertex] = @[
    Vertex(pos: Vector(x: -0.5, y: -0.5), color: Color(r: 255, g: 0, b: 0, a: 255)),
    Vertex(pos: Vector(x: 0.5, y: -0.5), color: Color(r: 0, g: 255, b: 0, a: 255)),
    Vertex(pos: Vector(x: -0.5, y: 0.5), color: Color(r: 0, g: 0, b: 255, a: 255)),
    Vertex(pos: Vector(x: 0.5, y: -0.5), color: Color(r: 0, g: 255, b: 0, a: 255)),
    Vertex(pos: Vector(x: 0.5, y: 0.5), color: Color(r: 255, g: 255, b: 255, a: 255)),
    Vertex(pos: Vector(x: -0.5, y: 0.5), color: Color(r: 0, g: 0, b: 255, a: 255)),
]
var vao: GLuint
var vbo: GLuint

#proc addPoint(pos: Vector, color: Color) =
#    vertices.add(Vertex(pos: pos, color: color))

proc initRenderer*() =
    # Init shader
    program = compileShaderProgram(vertexShaderCode, fragmentShaderCode)
    glUseProgram(program)
    var ar_loc = glGetUniformLocation(program, "ar")
    var vert_loc = glGetAttribLocation(program, "vert")
    var col_loc = glGetAttribLocation(program, "vertColor")

    # Init buffers
    glDisable(GL_BLEND)
    glDisable(GL_DEPTH_TEST)
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1)
    glGenVertexArrays(1, addr vao);
    glBindVertexArray(vao);
    glGenBuffers(1, addr vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glEnableVertexAttribArray((GLuint)vert_loc);
    glVertexAttribPointer((GLuint)vert_loc, 2, cGL_FLOAT, false, (GLsizei)Vertex.sizeof, nil)
    glEnableVertexAttribArray((GLuint)col_loc);
    glVertexAttribPointer((GLuint)col_loc, 4, GL_UNSIGNED_BYTE, true, (GLsizei)Vertex.sizeof,
        cast[pointer](float32.sizeof * 2))

    glUniform1f(ar_loc, 800.0/600.0)
    echo vertices
    echo cast[int](vertices.addr)
    #var test = Vertex(pos: Vector(x: -0.5, y: -0.5), color: Color(r: 255, g: 0, b: 0, a: 255))
    #glBufferData(GL_ARRAY_BUFFER, 1 * Vertex.sizeof, addr test, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, vertices.len * Vertex.sizeof, addr vertices[0], GL_STATIC_DRAW);


proc freeRenderer*() =
    if glIsBuffer(vbo):
        glDeleteBuffers(1, addr vbo)

    if glIsVertexArray(vao):
        glDeleteVertexArrays(1, addr vao)

    if glIsProgram(program):
        glDeleteProgram(program)

proc showRenderer*() =
    glUseProgram(program);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);