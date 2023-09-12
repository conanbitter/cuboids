import opengl
import vectors
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
    thickness*: float32
    bounds*: Vector


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


proc free*(self: Renderer) =
    if glIsBuffer(self.vbo):
        glDeleteBuffers(1, addr self.vbo)

    if glIsVertexArray(self.vao):
        glDeleteVertexArrays(1, addr self.vao)

    if glIsProgram(self.program):
        glDeleteProgram(self.program)

proc startRender*(self: Renderer) =
    glClearColor(0.1, 0.1, 0.1, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
    glUseProgram(self.program)
    glBindVertexArray(self.vao)
    self.state = RendererState.Ready

proc beginDraw*(self: Renderer, renderType: RenderType) =
    if self.state == RendererState.NotReady: return
    self.vertices.setLen(0)
    case renderType:
    of RenderType.Points:
        self.state = RendererState.DrawingPoints
    of RenderType.Lines:
        self.state = RendererState.DrawingLines
        self.isNewLine = true

proc addPoint*(self: Renderer, pos: Vector, color: Color) =
    let newVertex = Vertex(pos: pos, color: color)
    if self.state == RendererState.DrawingPoints:
        self.vertices.add(newVertex)
    elif self.state == RendererState.DrawingLines:

        if self.isNewLine:
            self.isNewLine = false
        else:
            self.vertices.add(self.lastVertex)
            self.vertices.add(newVertex)
        self.lastVertex = newVertex

proc newLine*(self: Renderer) =
    self.isNewLine = true

proc endDraw*(self: Renderer) =
    var drawType: GLenum = GL_KEEP # dummy value

    if self.state == RendererState.DrawingPoints:
        drawType = GL_POINTS
    elif self.state == RendererState.DrawingLines:
        drawType = GL_LINES

    if drawType != GL_KEEP:
        glBufferData(GL_ARRAY_BUFFER, self.vertices.len * Vertex.sizeof, addr self.vertices[0], GL_DYNAMIC_DRAW)
        glDrawArrays(drawType, 0, (GLsizei)self.vertices.len)
        self.state = RendererState.Ready

proc finishRender*(self: Renderer) =
    self.state = RendererState.NotReady

const thickRate: float32 = 1080.0/3.0

proc setViewport*(self: Renderer, width, height: int) =
    glViewport(0, 0, width.GLsizei, height.GLsizei)
    let newAr = width.float32/height.float32
    glUniform1f(self.ar_loc, newAr)
    var newThickness = height.float32/thickRate
    if newThickness < 1.0: newThickness = 1.0
    glLineWidth(newThickness)
    glPointSize(newThickness)
    self.thickness = newThickness/height.float32
    self.bounds = Vector(x: newAr, y: 1.0)
