import nimgl/[opengl, glfw]
import std/random
import math
import obj_loader

randomize()

proc GameShow();
proc GameInit();
proc ShowGUI();
proc PlayerShoot();
proc PlayerMove();
proc CameraApply();
proc CameraRotation(xAngle, zAngle: float);
proc GravityCalc();
proc RespawnCamera();


const 
  pW = 40
  pH = 40
  enemyCnt = 40

type
  TColor* = object 
    r*, g*, b*: float
  TCell* = object 
    color*: TColor
  Camera* = object 
    x*, y*, z*, dz*, rotX*, rotZ*: float
  Enemy* = object
    x*, y*, z*: float
    active*: bool


var camera: Camera = Camera(x:20f, y:20f, z:1.7f, rotX: 70, rotZ: -0)

var map: seq[seq[TCell]] 

var objModel = loadObjTest("assets\\models\\chel\\chel.obj")

proc MapInit() =
  # add
  for i in 1..pW:
    var row: seq[TCell]
    for j in 1..pH:
      let dc = (rand(100) mod 20 ).float * 0.01
      var cell: TCell
      cell.color.r = 0.31 + dc
      cell.color.g = 0.5 + dc
      cell.color.b = 0.13 + dc
      row.add(cell)
    map.add(row)

var enemys: seq[Enemy]

proc EmenyInit() =
  for i in 1..enemyCnt:
    enemys.add(Enemy(x: (rand(100) mod pW).float, y: (rand(100) mod pH).float, z: (rand(100) mod 5).float, active: true))

var
  window_width: int32 = 1280
  window_height: int32 = 720 
  window_focus: bool = true
  cursorX: float64 = 0
  cursorY: float64 = 0
  mouse_sensitivity: float64 = 0.2  # (0, 1]
  gravity = 0.004


var showMask = false

var kube = @[
  0f,0,0,
  0,1,0,
  1,1,0,
  1,0,0,
  0,0,1,
  0,1,1,
  1,1,1,
  1,0,1,
]

var kubeInd = @[
  0.Gluint,1,2,  
  2,3,0, 
  4,5,6, 
  6,7,4,  
  3,2,5,  
  6,7,3, 
  0,1,5,  
  5,4,0,
  1,2,6, 
  6,5,1, 
  0,3,7, 
  7,4,0,
]

# callbacks

proc focus(window: GLFWwindow, focused: bool){.cdecl.} =
  window_focus = focused

proc resize(window: GLFWwindow, width: int32, height: int32){.cdecl.} =
    window_width = width
    window_height = height
    glViewport(0, 0, width, height)
    glLoadIdentity()
    let koef = width / height
    let size = 0.1
    glFrustum(-koef*size, koef*size,  -size, size,  size*2, 100)

proc mouseButton(window: GLFWwindow, button: int32, action: int32, mods: int32){.cdecl.} =
    if button == GLFWMouseButton.Button1 and action == GLFWPress:
        PlayerShoot()

proc keyEnter(window: GLFWwindow, key: int32, scancode: int32, action: int32, mods: int32){.cdecl.} =
  if action == GLFWPress or action == GLFWRepeat:
    if key == int(GLFWKey.Escape): #256
      window.setWindowShouldClose(true)


doAssert glfwInit()

var window = glfwCreateWindow(window_width, window_height, "GAME ENGINE") 
window.setInputMode(GLFWCursorSpecial, GLFW_CURSOR_DISABLED)
window.getCursorPos(addr cursorX, addr cursorY)
discard window.setWindowSizeCallback(GLFWWindowsizeFun(resize))
discard window.setKeyCallback(GLFWKeyFun(keyEnter))
discard window.setWindowFocusCallback(GLFWWindowfocusFun(focus))
discard window.setMouseButtonCallback(mouseButton.GLFWMousebuttonFun)
window.makeContextCurrent()

doAssert glInit()

  
#glFrustum(-1,1, -1,1, 2, 80)

proc RespawnCamera() =
  camera.x = 20f 
  camera.y = 20f 
  camera.z = 1.7f 
  enemys = @[]
  EmenyInit()
  for i in 0..enemys.len-1:
    enemys[i].active = true

proc GravityCalc()=
  #stay on 
  if (camera.x > 0) and (camera.y > 0) and (camera.x < 40 ) and (camera.y < 40) and (round(camera.z*10f) == 17f):
    #force up
    if window.getKey(GLFWKey.Space) > 0:  
      camera.z += 2f
  else:
    camera.z -= 0.1f

proc ShowGUI()=
    glPushMatrix()
    glLoadIdentity()
    glOrtho(0, window_width.float, window_height.float, 0, -1, 1)
    glLineWidth(3)
    glBegin(GL_LINES)
    glColor3f(0,0,0)
    glVertex2f(window_width/2-20,window_height/2+5)
    glVertex2f(window_width/2+20,window_height/2+5)
    glVertex2f(window_width/2+5,window_height/2+20)
    glVertex2f(window_width/2+5,window_height/2-20)
    glEnd()
    glPopMatrix()

proc EnemyShowOld() =
  glEnableClientState(GL_VERTEX_ARRAY)
  glVertexPointer(3, EGL_FLOAT, 0, kube[0].addr)
  for i in 0..enemyCnt-1:
    if enemys[i].active: 
      glPushMatrix()
      glTranslatef(enemys[i].x, enemys[i].y, enemys[i].z)
      glColor3ub(255-i.GLubyte,0,0)     
      glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, kubeInd[0].addr)
      glPopMatrix()
  glDisableClientState(GL_VERTEX_ARRAY)

proc EnemyShow() =
  glEnableClientState(GL_VERTEX_ARRAY)
  glVertexPointer(3, EGL_FLOAT, 0, objModel.vertexies[0].addr)
  for i in 0..enemyCnt-1:
    if enemys[i].active: 
      glPushMatrix()
      glTranslatef(enemys[i].x, enemys[i].y, enemys[i].z)
      glColor3ub(255-i.GLubyte,0,0)     
      glDrawElements(GL_TRIANGLES, objModel.vertexies.len.GLint*2, GL_UNSIGNED_INT, objModel.indexes[0].addr)
      glPopMatrix()
  glDisableClientState(GL_VERTEX_ARRAY)

proc CameraApply() =
  glRotatef(-camera.rotX, 1, 0, 0)
  glRotatef(-camera.rotZ, 0, 0, 1)
  glTranslatef(-camera.x,-camera.y,-camera.z)

proc CameraRotation(xAngle, zAngle: float)=
  camera.rotZ += zAngle
  if camera.rotZ < 0: camera.rotZ+=360f
  if camera.rotZ > 360f: camera.rotZ-=360f
  camera.rotX += xAngle
  if camera.rotX < 0: camera.rotX = 0 
  if camera.rotX > 180: camera.rotX = 180f

proc PlayerMove()= 
  if not window_focus: return

  var 
    angle = -camera.rotZ / 180f * PI
    speed = 0f
  
  let
    W = window.getKey(GLFWKey.W)
    S = window.getKey(GLFWKey.S)
    A = window.getKey(GLFWKey.A)
    D = window.getKey(GLFWKey.D)
    R = window.getKey(GLFWKey.R)

  if R > 0:
    RespawnCamera()    
    
  if W > 0 and S == 0:
    speed = 0.1f
    if A > 0:
      speed = 0.1f
      angle -= PI*0.25 
    if D > 0:  
      speed = 0.1f
      angle += PI*0.25 
  elif S > 0 and W == 0:
    speed = 0.1f
    angle += PI
    if A > 0:
      speed = 0.1f
      angle += PI*0.25 
    if D > 0:  
      speed = 0.1f
      angle -= PI*0.25 
  elif A > 0 and D == 0:
    speed = 0.1f
    angle -= PI*0.5 
  elif D > 0 and A == 0:
    speed = 0.1f
    angle += PI*0.5 
  
  camera.x += sin(angle) * speed
  camera.y += cos(angle) * speed
  
  GravityCalc()

  var
    posX: float64 = 0f
    posY: float64 = 0f
    d_cursorX: float64 = 0f
    d_cursorY: float64 = 0f
  window.getCursorPos(addr posX, addr posY)  
  d_cursorY = cursorY - posY
  d_cursorX = cursorX - posX
  cursorX = round(window_width/2)
  cursorY = round(window_height/2)
  window.setCursorPos(cursorX, cursorY)
  CameraRotation(d_cursorY*mouse_sensitivity, d_cursorX*mouse_sensitivity)

proc GameMove()=
  PlayerMove()

proc GameInit() = 
  glEnable(GL_DEPTH_TEST)
  # glEnable(GL_LIGHTING)
  # glEnable(GL_LIGHT0)
  # glEnable(GL_COLOR_MATERIAL)
  MapInit()
  EmenyInit() 
  window.resize(window_width, window_height)

  #отсебятина
  glClearColor(0.6, 0.8, 1, 0)
  cursorX = round(window_width/2)
  cursorY = round(window_height/2)
  window.setCursorPos(cursorX, cursorY)
  window.focusWindow()


proc GameShow() = 
  if showMask:
    glColor3f(0,0,0)
  else:  
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glPushMatrix()
  CameraApply()

  glEnableClientState(GL_VERTEX_ARRAY)
  glVertexPointer(3, EGL_FLOAT, 0, kube[0].addr)

  for i in 0..pW-1:   
    for j in 0..pH-1:
      glPushMatrix()
      glTranslatef(i.float, j.float, 0)
      if showMask:
        glColor3f(0,0,0)
      else: 
        glColor3f(map[i][j].color.r, map[i][j].color.g, map[i][j].color.b)
      glNormal3f(0f,0,1)
      glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, kubeInd[0].addr)
      glPopMatrix()
  glDisableClientState(GL_VERTEX_ARRAY)
  #EnemyShow()
  objModel.draw()
  glPopMatrix()

proc PlayerShoot()=
  showMask = true
  GameShow()
  showMask = false
  var clr: array[3, GLubyte]
  glReadPixels(cursorX.GLint, cursorY.GLint, 1, 1, GL_RGB, GL_UNSIGNED_BYTE, clr[0].addr)
  if clr[0] > 215:
    enemys[255-clr[0]].active = false

proc render(window: GLFWWindow) =      
  GameShow()
  ShowGUI()
  window.swapBuffers()

GameInit() 
while not window.windowShouldClose():
  GameMove()
  render(window)
  glfwPollEvents()

window.destroyWindow()
glfwTerminate()