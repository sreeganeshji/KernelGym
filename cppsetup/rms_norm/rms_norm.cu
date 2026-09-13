#include <cuda.h>
#include <vector>
#include <cstdlib>
#include <print>
#include <random>

using namespace std;

__global__ 
float reduce1(float* nums, int N) {

    float res = 0.0f;



    return res;
}

__global__
void rms_norm_kernel1(float* nums, int N) {

    __device__ __shared__ double rms = 0.0; //block scoped

    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if(i < N) {
        rms += nums[i] * nums[i];
        /*
        For reduction, access the blockDim/2 element based on the segment.
        
        */
    }

}

void rms_norm(std::vector<float>& nums) {
    /*
    Square each num
    Add them up
    divide by N
    get their squareroot
    then divide each element with that.
    */

    /*
    Each thread, warp, block run in parallel.
    */

}

int main(){
    using namespace std;

    // random_device dev;
    mt19937 r(42);
    uniform_real_distribution<float> dist(-1.0f, 1.0f);
    println("Rand number {}", dist(r));

    int N = 1024;
    vector<float> nums(N);

    for(float& num : nums) {
        num = dist(r);
    }



}