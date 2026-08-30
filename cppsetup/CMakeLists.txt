cmake_minimum_required(VERSION 3.28)

project(HelloWorld)

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
