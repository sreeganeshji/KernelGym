#include <cuda.h>
#include <vector>
#include <cstdlib>
#include <iostream>
#include <random>
# include <assert.h>
#include <cmath>
#include <algorithm>

using namespace std;

// #define CUDA_CHECK()
#define CUDA_CHECK(call) checkCuda((call), #call, __FILE__, __LINE__)

void checkCuda(cudaError_t result, const char* expression, const char* file, int line){
    if(!(result == cudaError::cudaSuccess)) {
        std::cerr << "Caught error: " << cudaGetErrorName(result) << ": "
                  << cudaGetErrorString(result) << '\n';
        std::cerr << "Details: " << expression << ",\n file: " << file
                  << ",\n line: " << line << '\n';
    }
}

__global__ 
void reduce1(float* nums, int N) {
}

__global__
void rms_norm_kernel1(float* nums, float* sum, int N) {

    __shared__ float rms_block[1024]; //block scoped blockDim=1024

    int segment = blockDim.x * 2 *blockIdx.x;
    int i = segment + threadIdx.x;
    int t = threadIdx.x;

    float sq1 = (i<N) ? nums[i] * nums[i] : 0.0f;
    float sq2 = (i+blockDim.x < N) ? (nums[i+blockDim.x] * nums[i+blockDim.x]) : 0.0f;
    rms_block[t] = sq1 + sq2;

    // if(t<10) {
    //     printf("rms_block[%d]: %f \n", t, rms_block[t]);
    // }

    for(int s=blockDim.x/2; s>=1; s=s/2) {

        __syncthreads();

        if(t<s) {
            rms_block[t] = rms_block[t] + rms_block[t+s];
        }
    }

    if(t == 0) {
        printf("Sum is %f \n", rms_block[0]);
        atomicAdd(sum, rms_block[0]);
    }

}

__global__
void divide_x_by_kernel(float* nums, float div, int N) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if(i < N) {
        nums[i] = nums[i]/div;
    }
}

__global__
void divide_x_by_kernel(float* nums, float* sum, int N) {
    
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if(i < N) {
        float rms = sqrtf(*sum/N);
        nums[i] = nums[i]/rms;
    }
}

vector<float> rms_norm(std::vector<float>& nums) {
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
   int block_dim = 1024;

   int N = nums.size();

    dim3 gridDim (max(static_cast<int>(ceil(static_cast<float>(nums.size())/(2*block_dim))), 1));
    dim3 blockDim (block_dim);

    float* nums_d;
    float* sum_d;

    CUDA_CHECK(cudaMalloc(&nums_d, sizeof(float) * N));
    CUDA_CHECK(cudaMalloc(&sum_d, sizeof(float)));
    

    CUDA_CHECK(cudaMemcpy(nums_d, nums.data(), N*sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemset(sum_d, 0.0f, sizeof(float)));

    cout<<"Startinng kernel with gridDim:"<<gridDim.x<<" and blockDim:"<<blockDim.x<<endl;

    rms_norm_kernel1<<<gridDim, block_dim>>>(nums_d, sum_d, N);

    CUDA_CHECK(cudaGetLastError());

    // CUDA_CHECK(cudaDeviceSynchronize());

    // float* sum = static_cast<float*>(malloc(sizeof(float)));
    float sum;

    CUDA_CHECK(cudaMemcpy(&sum, sum_d, sizeof(float), cudaMemcpyDeviceToHost));

    cout<<"Got back sum "<< sum<<endl;

    /*
    We don't need to pass these, or call cudaDeviceSync because we're passing the sum_d directly to the next kernel
    float rms = sum/N;

    cout <<"rms before root: "<<rms<<endl;

    rms = sqrt(rms);

    cout <<"Rms: "<<rms<<endl;

    */

    dim3 divGridDim(max(static_cast<int>(ceil(static_cast<float>(N)/block_dim)), 1));

    // cudaMemcpy(sum_d, &rms, sizeof(float), cudaMemcpyHostToDevice);

    // divide_x_by_kernel<<<divGridDim, blockDim>>>(nums_d, rms, N);
    divide_x_by_kernel<<<divGridDim, blockDim>>>(nums_d, sum_d, N);
    CUDA_CHECK(cudaGetLastError());


    // float rms_x[N];

    vector<float> res(N);

    CUDA_CHECK(cudaMemcpy(res.data(), nums_d, sizeof(float) * N, cudaMemcpyDeviceToHost));

    CUDA_CHECK(cudaFree(nums_d));
    CUDA_CHECK(cudaFree(sum_d));
    // free(sum);

    

    // for(int i=0; i<N; i++) {
    //     res[i] = rms_x[i];
    // }

    return res;
}

vector<float> rms_norm_cpu(vector<float> nums) {
    float sq_sum = 0;
    int N = nums.size();

    for(float& num : nums) {
        sq_sum += num * num;
    }

    float rms = sq_sum/N;
    rms = sqrt(rms);

    cout <<"CPU RMS "<<rms<<endl;

    vector<float> res(N);

    for(int i=0; i<N; i++) {
        res[i] = nums[i]/rms;
    }

    return res;
}

float max_abs_diff(vector<float>& v1, vector<float>& v2) {
    int N = v1.size();
    assert(v1.size() == v2.size());
    float max_diff = 0.0f;

    for(int i=0; i<N; i++) {
        max_diff = std::max(max_diff, std::fabs(v1[i] - v2[i]));
    }

    return max_diff;
}

int main(){
    using namespace std;

    // random_device dev;
    mt19937 r(42);
    uniform_real_distribution<float> dist(-1.0f, 1.0f);
    cout << "Rand number " << dist(r) << '\n';

    int N = 3000;
    vector<float> nums(N);

    for(float& num : nums) {
        num = dist(r);
        // num = 2.0f;
    }

    float cpu_sum = 0.0f;

    for(float& num: nums) {
        cpu_sum += num * num;
    }

    cout <<"CPU sum is "<<cpu_sum<<endl;
    vector<float> cpu_res = rms_norm_cpu(nums);
    vector<float> res = rms_norm(nums);

    for(int i=0; i<10; i++) {
        cout<<"nums["<<i<<"]: "<<nums[i]<<" res["<<i<<"] = "<<res[i]<<" cpu_res["<<i<<"] = "<<cpu_res[i]<<endl;
    }

    //Finding max abs diff.
    cout<<"Max abs diff: "<<max_abs_diff(res, cpu_res)<<endl;

    return 0;

}