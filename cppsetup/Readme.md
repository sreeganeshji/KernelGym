Start by checking whether these are installed:
`apt list cmake g++ gdb make ninja* rsync zip`
[wiki](https://learn.microsoft.com/en-us/cpp/build/walkthrough-build-debug-wsl2?view=msvc-170)

If they're not, then run
```
sudo apt update
sudo apt install cmake g++ gdb make ninja* rsync zip
```

A cmake project is one with the `CMakeLists.txt` file in it. [tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)

cmake is a config system, which doesn't actually build anything but generate configs based on env, user settings, etc.
So it generates build systems. Like ninja, etc. you can find these under cmake-generators.

You can find it inside `cmake -G` and the default is Unix Makefile, but there's also the Ninga option, in windows, there's the VS as well.

In choosing these generators, one thing to consider is the flavors that they support, for instance, you might want the debug, release, etc. 

a few flags,
-S: Source dir, -B build dir where the outs will be generated.

The lists file is also called CML.

There's this whole reference which can be downloaded from [here](https://cmake.org/cmake/help/latest/_downloads/93f69cd753f1778ad3f0adbb356f0781/cmake-4.4.3-tutorial-source.zip)

Btw for building an executable these were somelearnings

make file should start with min version, and program() giving a name to your project. lower case is preferred.

```
minimum_cmake_version(VERSION 3.18)
program(HelloWorld)
```

Then executables are the name/label given to all the set of source files and other linking data, etc. are collected under.

```
add_executable(HelloWorldExe)
target_sources(HelloWorldExe PRIVATE helloworld.cpp)
```

You would add these other files to that executable which are called as targets.

and when you're ready, you call `cmake -B Build` for creating the build artifacts, this is one time. Then to actually build your project, i guess to compile and get you the output, you call `cmake --build Build` pointing to the `Build/` folder. You can edit the cpp file and just run this to get you the compiler errors, etc. and the output. Also, this should place the output in the Build/ folder which you can now execute.

### Moving on towards the libraries.

So this one has new flags, lingo etc. under the `target_sources`, we say 
```
target_sources(MyEXE
    PRIVATE
        helloworld.cpp
    
    PUBLIC
        FILE_SET headerset
        FILE_TYPE HEADERS
        BASE_DIR /headers/
        FILES
            /headers/myheader.h
)
```

the fileset name can be skipped if its the same as header and we can combine it to `FILE_SET HEADERS`.

Btw I did this interesting mistake where I enclosed the main() within an anonymous namespace as supposed to leaving it in the global namespace which ended up in the error saying that the reference to main is undefined.

```c++
// THIS IS A MISTAKE!!
namespace {
    int main() {
        // Stuff
        return 0;
    }
}

namespace ABC {
    // other implemenations
}

```

## Linking libraries and executables together
This is done using the attribute `target_link_libraries()`. 
```
target_link_libraries(
    MyProgram
        PRIVATE
            MyLibrary
)
```

There are three scopes, PRIVATE, INTERFACE, and PUBLIC.
Private is a property that is only available to the targets that own it. For ex. the private headers would be only visible to the targets that attach to it.
INTERFACE is a property for the targets that link to the owning targets. Like header only library target that doesn't really build anything, so the consuming targets would be using it as an interface.
public is a union of both. 

```
target_sources(
    MyLibrary
        PRIVATE
            FILE_SET InternalOnlyHeaders
            FILE_TYPE HEADERS
            BASE_DIR 
                include
            FILES
                include/InternalOnlyHeaders.h
        
        INTERFACE
            FILE_SET ConsumerOnlyHeaders
            FILE_TYPE HEADERS
            BASE_DIR
                include
            FILES
                include/ConsumerOnlyHeaders.h
        
        PUBLIC
            FILE_SET publicHeaders
            FILE_TYPE HEADERS
            FILES
                publicheaders.h
)
```