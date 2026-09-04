#include "include/logging_helper.h"
#include "include/math_helper.h"

MathHelper::MathHelper(int var1): var1_int(var1) {}

int MathHelper::Twice(){
    var1_int *= 2;
    return var1_int;
}

int MathHelper::Thrice(){
    var1_int *=3;
    return var1_int;
}