#include<stdio.h>
#include<iostream>
// #include<print>
#include "include/logging_helper.h"


int main() {
    MyLogging::Logger l;
    l.Log("Hello world");

    return 0;
}

void MyLogging::Logger::Log(std::string s) {
    std::cout<<s<<std::endl;
}
