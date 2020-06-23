# Linux.Cephei

This is a POC ELF prepender written in Nim. I like writting prependers on languages that I'm learning and find interesting. Nim is a very nice one!    
It is probably the first binary infector ever written in this language, that's neat.    
The above affirmation is based on SPTH LIP page: http://spth.virii.lu/LIP.html


# Build
Build with:

```$ nim c -d:release --passL:-static cephei.nim```

You can also build with Docker: 

```$ docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app nimlang/nim:alpine nim c -d:release --passL:-static cephei.nim```

Note that Nim version used was 0.17.0, the latest at this moment.

# Binary Sample
A static binary sample is also available at https://www.guitmz.com/linux.cephei
```
$ file linux.cephei
ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, not stripped
```

# Demo
[![asciicast](https://asciinema.org/a/RIYDinGMsBqCNOKi8K2MakSoF.png)](https://asciinema.org/a/RIYDinGMsBqCNOKi8K2MakSoF)
