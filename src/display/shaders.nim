import opengl

type Shader* = GLuint

proc getShaderLog(shader: GLuint): string =
    if glIsShader(shader):
        var infoLogLength: GLsizei = 0
        var maxLength: GLint = 0

        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr maxLength)
        var infoLog = newString(maxLength)

        glGetShaderInfoLog(shader, maxLength, addr infoLogLength,
                infoLog.cstring)
        if infoLogLength > 0:
            return infoLog
        else:
            return ""
    else:
        return "Wrong shader handle"

proc getProgramLog(shaderProgram: GLuint): string =
    if glIsProgram(shaderProgram):

        var infoLogLength: GLsizei = 0
        var maxLength: GLint = 0

        glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, addr maxLength)
        var infoLog = newString(maxLength)

        glGetProgramInfoLog(shaderProgram, maxLength, addr infoLogLength,
                infoLog.cstring)
        if infoLogLength > 0:
            return infoLog
        else:
            return ""
    else:
        return "Wrong shader program handle"

proc compileShader(source: string, shaderType: GLenum): GLuint =
    let shader = glCreateShader(shaderType)
    let lines = allocCStringArray([source])
    glShaderSource(shader, 1, lines, nil)
    glCompileShader(shader)
    deallocCStringArray(lines)
    var isCompiled: GLint = (GLint)GL_FALSE
    glGetShaderiv(shader, GL_COMPILE_STATUS, addr isCompiled)
    if ((GLBoolean)isCompiled) != GL_TRUE:
        var msg: string
        if shaderType == GL_VERTEX_SHADER:
            msg = "Vertex shader compile error: "
        elif shaderType == GL_FRAGMENT_SHADER:
            msg = "Fragment shader compile error: "
        else:
            msg = "Shader compile error: "
        echo msg & getShaderLog(shader)
        return 0
    return shader

proc compileShaderProgram*(vertexShaderCode: string, fragmentShaderCode: string): Shader =
    let program = glCreateProgram()

    let compiledVertexShader = compileShader(vertexShaderCode, GL_VERTEX_SHADER)
    let compiledFragmentShader = compileShader(fragmentShaderCode, GL_FRAGMENT_SHADER)

    if compiledVertexShader == 0 or compiledFragmentShader == 0:
        return 0

    glAttachShader(program, compiledVertexShader)
    glAttachShader(program, compiledFragmentShader)
    glLinkProgram(program)
    var isLinked = (GLint)GL_FALSE
    glGetProgramiv(program, GL_LINK_STATUS, addr isLinked)
    if ((GLboolean)isLinked) != GL_TRUE:
        echo "Shader link error: " & getProgramLog(program)
        return 0
    glDeleteShader(compiledVertexShader)
    glDeleteShader(compiledFragmentShader)
    return program
