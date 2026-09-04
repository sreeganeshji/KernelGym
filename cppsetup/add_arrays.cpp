#include <print>

int main() {
    using namespace std;
    for (int i=0; i<100; i++) {
        std::println("1<<{}: {}", i, 1<<i);
    }

    println("{}",INTMAX_MAX);

    int N = 1<<2;
    std::print("Hello World {}", N);
    return 0;
}