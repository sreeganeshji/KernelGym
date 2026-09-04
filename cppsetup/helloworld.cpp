#include<stdio.h>
#include<iostream>
#include <print>
// #include<print>
#include "include/logging_helper.h"
#include "include/math_helper.h"


int main() {
    MyLogging::Logger l;
    l.Log("Hello world");

    MathHelper mh(10);
    l.Log(std::to_string(mh.Thrice()));
    return 0;
}

void MyLogging::Logger::Log(std::string s) {
    std::cout<<s<<std::endl;
}
