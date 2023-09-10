import display/window
import geometry

const test = newGeometry(@[Vector(x: 1.0, y: 1.0), Vector(x: 0.5, y: -0.5)])
echo test

let wnd = newWindow()
wnd.run()
