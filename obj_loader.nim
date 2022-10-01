import nimgl/[opengl, glfw]
import os
import strutils
import math


type
  Model* = object
    comments*: seq[string]
    name*: string
    mtllib*: string
    vertexies*: seq[GLfloat]
    testvert*: seq[GLfloat]
    testnormal*: seq[GLfloat]
    normals*: seq[GLfloat]
    uv_map*: seq[GLfloat]
    colors*: seq[GLfloat]
    indexes*: seq[GLint]
    ancerPiont*: array[3, GLfloat]


proc parseColorByMaterialName(materialName: string, mtlStr: string): array[3, GLfloat] =
    let a = find(mtlStr, "newmtl " & materialName, 0)
    assert a != -1 , "error, not found material"
    let b = find(mtlStr, "\nKd ", a)
    let c = find(mtlStr, "\n", b+3)
    let colorText = mtlStr[b+4..c-1]
    
    result[0] = parseFloat(split(colorText)[0]).GLfloat
    result[1] = parseFloat(split(colorText)[1]).GLfloat
    result[2] = parseFloat(split(colorText)[2]).GLfloat
                

proc loadObj*(path: string = "assets\\models\\sphere\\sphere.obj"): Model =
  var strs = split(readFile(path), "\n")
  var mtlText: string
  var currentColor: array[3, GLfloat]  
  for str in strs:
    if str.len > 2:
        let spletter_str = split(str)
        case spletter_str[0]:   
            of "#":
                result.comments.add(str[2..(str.len-1)])
            of "v":
                result.vertexies.add(spletter_str[1].parseFloat())
                result.vertexies.add(spletter_str[2].parseFloat())
                result.vertexies.add(spletter_str[3].parseFloat())
            of "vt":
                result.uv_map.add(spletter_str[1].parseFloat())
                result.uv_map.add(spletter_str[2].parseFloat())
            of "vn":
                result.normals.add(spletter_str[1].parseFloat())
                result.normals.add(spletter_str[2].parseFloat())
                result.normals.add(spletter_str[3].parseFloat())
            of "f":
                result.indexes.add((parseInt(split(spletter_str[1], "/")[0])-1).GLint)
                result.indexes.add((parseInt(split(spletter_str[2], "/")[0])-1).GLint)
                result.indexes.add((parseInt(split(spletter_str[3], "/")[0])-1).GLint)
                result.colors.add(currentColor)
            of "mtllib":
                mtlText = readFile(splitPath(path).head & "/" & spletter_str[1])
            of "usemtl":
                currentColor = parseColorByMaterialName(spletter_str[1], mtlText)


proc findAllVertexies(strs: seq[string]): seq[GLfloat] =
  for str in strs:
    if str.len > 2:
        let spletter_str = split(str)
        case spletter_str[0]:           
            of "v":
                result.add(spletter_str[1].parseFloat().GLfloat)
                result.add(spletter_str[2].parseFloat().GLfloat)
                result.add(spletter_str[3].parseFloat().GLfloat)

proc findAllNormals(strs: seq[string]): seq[GLfloat] =
  for str in strs:
    if str.len > 2:
        let spletter_str = split(str)
        case spletter_str[0]:           
            of "vn":
                result.add(spletter_str[1].parseFloat().GLfloat)
                result.add(spletter_str[2].parseFloat().GLfloat)
                result.add(spletter_str[3].parseFloat().GLfloat)
           

proc loadObjTest*(path: string = "assets\\models\\sphere\\sphere.obj"): Model =
  var strs = split(readFile(path), "\n")
  var mtlText: string
  var currentColor: array[3, GLfloat] 
  result.vertexies = findAllVertexies(strs)
  result.normals = findAllNormals(strs)
  for str in strs:
    if str.len > 2:
        let spletter_str = split(str)
        case spletter_str[0]:    
            of "#":
                result.comments.add(str[2..(str.len-1)])  
            of "vt":
                result.uv_map.add(spletter_str[1].parseFloat())
                result.uv_map.add(spletter_str[2].parseFloat())                   
            of "f":
                result.indexes.add((parseInt(split(spletter_str[1], "/")[0])-1).GLint)
                result.indexes.add((parseInt(split(spletter_str[2], "/")[0])-1).GLint)
                result.indexes.add((parseInt(split(spletter_str[3], "/")[0])-1).GLint)

                result.colors.add(currentColor)
                result.colors.add(currentColor)
                result.colors.add(currentColor)
                
                # вертексы

                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[1], "/")[0])-1)*3])
                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[1], "/")[0])-1)*3+1])
                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[1], "/")[0])-1)*3+2])


                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[2], "/")[0])-1)*3])
                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[2], "/")[0])-1)*3+1])
                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[2], "/")[0])-1)*3+2])


                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[3], "/")[0])-1)*3])
                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[3], "/")[0])-1)*3+1])
                result.testvert.add(result.vertexies[(parseInt(split(spletter_str[3], "/")[0])-1)*3+2])

                # нормали

                result.testnormal.add(result.normals[(parseInt(split(spletter_str[1], "/")[2])-1)*3])
                result.testnormal.add(result.normals[(parseInt(split(spletter_str[1], "/")[2])-1)*3+1])
                result.testnormal.add(result.normals[(parseInt(split(spletter_str[1], "/")[2])-1)*3+2])

                result.testnormal.add(result.normals[(parseInt(split(spletter_str[2], "/")[2])-1)*3])
                result.testnormal.add(result.normals[(parseInt(split(spletter_str[2], "/")[2])-1)*3+1])
                result.testnormal.add(result.normals[(parseInt(split(spletter_str[2], "/")[2])-1)*3+2])

                result.testnormal.add(result.normals[(parseInt(split(spletter_str[3], "/")[2])-1)*3])
                result.testnormal.add(result.normals[(parseInt(split(spletter_str[3], "/")[2])-1)*3+1])
                result.testnormal.add(result.normals[(parseInt(split(spletter_str[3], "/")[2])-1)*3+2])

            of "mtllib":
                mtlText = readFile(splitPath(path).head & "/" & spletter_str[1])
            of "usemtl":
                currentColor = parseColorByMaterialName(spletter_str[1], mtlText)



proc draw*(objModel:var Model): void =  
  glEnableClientState(GL_VERTEX_ARRAY)
  glVertexPointer(3, EGL_FLOAT, 0, objModel.testvert[0].addr)
  glEnableClientState(GL_COLOR_ARRAY)
  glColorPointer(3, EGL_FLOAT, 0, objModel.colors[0].addr)
  glEnableClientState(GL_NORMAL_ARRAY)
  glNormalPointer(EGL_FLOAT, 0, objModel.testnormal[0].addr)
  
  glPushMatrix()
  glTranslatef(15,20,0.1)
  glRotatef(90f,1,0,0)   
  glRotatef(90f,0,1,0) 
  glDrawArrays(GL_TRIANGLES, 0, round(objModel.testvert.len/3).GLSizei)
  glPopMatrix()

  glDisableClientState(GL_VERTEX_ARRAY)
  glDisableClientState(GL_COLOR_ARRAY)
  glDisableClientState(GL_NORMAL_ARRAY)