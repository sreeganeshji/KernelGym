cmake_minimum_required(VERSION 4.4)

project(ArrayAdd LANGUAGES CUDA CXX)
set(CMAKE_CXX_STANDARD 23)

set(CMAKE_CUDA_STANDARD 23)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

add_executable(ArryAdd)
target_sources(ArryAdd
    PRIVATE
        add_arrays/add_arrays.cpp
        add_arrays/add_arrays.cu
        add_arrays/add_arrays.h
        add_arrays/add_arrays_old.cu
)

add_executable(CudaArch)
target_sources(CudaArch 
PRIVATE
z_architecture_and_scheduling/querying_device_props.cu
)

add_executable(HelloExe)

target_sources(HelloExe
PRIVATE
helloworld.cpp

PUBLIC
FILE_SET HEADERS
BASE_DIRS 
    include
FILES
    include/logging_helper.h
)

add_library(Math)

target_sources(Math
    PRIVATE
        mathhelpers.cpp

    PUBLIC
    FILE_SET HEADERS
    FILES
    include/math_helper.h
)

target_link_libraries(HelloExe
PRIVATE
Math
)