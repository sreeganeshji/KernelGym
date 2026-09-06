#include "reduction.h"
#include <vector>
#include <print>

int main() {
    std::vector<float> nums(2048, 1.0f);

    float sumcuda = reduction::ReduceSum(nums);

    float sumcpu = 0.0f;

    for(auto num: nums) {
        sumcpu += num;
    }

    std::println("sumcpu: {}, sumgpu: {}", sumcpu, sumcuda);

    return 0;
}