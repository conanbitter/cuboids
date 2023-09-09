# Package

version          = "0.1.0"
author           = "Conan Bitter"
description      = "A simple Asteroids game"
license          = "MIT"
srcDir           = "src"
binDir           = "bin"
namedBin["main"] = "cuboids"

# Dependencies

requires "nim >= 2.0.0"
requires "staticglfw >= 4.1.3"