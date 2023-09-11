import opengl
import ../geometry
import shaders

type RendererState = enum
    Ready, NotReady, DrawingLines, DrawingPoints

type RenderType* = enum
    Lines, Points

type Color* = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

type Vertex {.packed.} = object
    pos: Vector
    color: Color

type Renderer* = ref object
    program: GLuint
    vao: GLuint
    vbo: GLuint
    ar_loc: GLint
    state: RendererState
    vertices: seq[Vertex]
    lastVertex: Vertex
    isNewLine: bool
    thickness: float32


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
    result = Renderer(state: RendererState.NotReady)

    loadExtensions()
    # Set properties
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glEnable(GL_LINE_SMOOTH)
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST)

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
    ren.state = RendererState.Ready

proc beginDraw*(ren: Renderer, renderType: RenderType) =
    if ren.state == RendererState.NotReady: return
    ren.vertices.setLen(0)
    case renderType:
    of RenderType.Points:
        ren.state = RendererState.DrawingPoints
    of RenderType.Lines:
        ren.state = RendererState.DrawingLines
        ren.isNewLine = true

proc addPoint*(ren: Renderer, pos: Vector, color: Color) =
    let newVertex = Vertex(pos: pos, color: color)
    if ren.state == RendererState.DrawingPoints:
        ren.vertices.add(newVertex)
    elif ren.state == RendererState.DrawingLines:

        if ren.isNewLine:
            ren.isNewLine = false
        else:
            ren.vertices.add(ren.lastVertex)
            ren.vertices.add(newVertex)
        ren.lastVertex = newVertex

proc newLine*(ren: Renderer) =
    ren.isNewLine = true

proc endDraw*(ren: Renderer) =
    var drawType: GLenum = GL_KEEP # dummy value

    if ren.state == RendererState.DrawingPoints:
        drawType = GL_POINTS
    elif ren.state == RendererState.DrawingLines:
        drawType = GL_LINES

    if drawType != GL_KEEP:
        glBufferData(GL_ARRAY_BUFFER, ren.vertices.len * Vertex.sizeof, addr ren.vertices[0], GL_DYNAMIC_DRAW)
        glDrawArrays(drawType, 0, (GLsizei)ren.vertices.len)
        ren.state = RendererState.Ready

proc finishRender*(ren: Renderer) =
    ren.state = RendererState.NotReady

const thickRate: float32 = 1080.0/3.0

proc setViewport*(ren: Renderer, width, height: int) =
    glViewport(0, 0, (GLsizei)width, (GLsizei)height)
    glUniform1f(ren.ar_loc, ((float32)width)/((float32)height))
    var newThickness = ((float32)height)/thickRate
    if newThickness < 1.0: newThickness = 1.0
    glLineWidth(newThickness)
    glPointSize(newThickness)
    ren.thickness = newThickness/((float32)height)
    echo ren.thickness
