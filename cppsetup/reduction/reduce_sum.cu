#include <cuda.h>
#include <vector>
#include <print>

#define CUDA_CHECK(call) checkCuda((call), #call, __FILE__, __LINE__)

void checkCuda(cudaError_t result, const char* expression, const char* file, int line){
    if(!(result == cudaError::cudaSuccess)) {
        std::println("Caught error: {}: {}", cudaGetErrorName(result), cudaGetErrorString(result));
        std::println("Details: {},\n file: {},\n line: {}", expression, file, line);
    }
}

namespace reduction{
    __global__
    void ReduceSumKernel(float* nums, float* sum) {
        /*
            Each block has 1024 threads. Say if nums is 2048 emenets wide, then each thread can look at nums[2*i] where i=threadidx, 0, 2, 4, etc.
            But then this needs to be passed over for the next threads to use. Is this where registers come into play? 
            Won't it be local to this thread?
            We can overrite the input!
            0 1 2 3 4 5 6 7 8
            0   2   4   6
            0       4
            0
        */
    //    printf("Reached the device");
        int i = blockDim.x * blockIdx.x + threadIdx.x;

        // if (i<10) printf("reached i: %d, blockId: %d, blockdim: %d \n", i, blockIdx.x, blockDim.x);

        for(int s=1; s <= blockDim.x ; s*=2) {
            // if(i*s %2 == 0) {
            if(i*s + s < blockDim.x * 2) {
                // if (i<20) printf("threadID: %d, i:%d, s: %d, i*s: %d, i*s+s: %d \n", threadIdx.x, i, s, i*s, i*s+s);
                // if (i<20) ("threadID: %d, i:%d, s: %d, nums[%d]: %f, nums[%d]: %f \n", threadIdx.x, i, i*s, nums[i*s], i*s+s, nums[i*s+s]);
                nums[i*s] = nums[i*s] + nums[i*s+s];
            }
            __syncthreads();
        }

        if(i==0)
        {
            *sum = nums[0];
        }
    }


    float ReduceSum(std::vector<float> nums) {
        int maxThreadsPerBlock = 1024;
        dim3 dimGrid(ceil(nums.size()/(2*maxThreadsPerBlock) + 1));
        dim3 dimBlock(1024);
        
        std::println("Got nums of size: {}", nums.size());

        float* nums_d;
        CUDA_CHECK(cudaMalloc(&nums_d, sizeof(float)*nums.size()));
        CUDA_CHECK(cudaMemcpy(nums_d, nums.data(), sizeof(float) * nums.size(), cudaMemcpyHostToDevice));

        float sum;
        float *sum_d;
        CUDA_CHECK(cudaMalloc(&sum_d, sizeof(float)));

        // printf("Callinng with dimGrid: %d, dimBlock: %d", dimGrid, dimBlock);

        ReduceSumKernel<<<dimGrid, dimBlock>>>(nums_d, sum_d);
        cudaDeviceSynchronize();
        CUDA_CHECK(cudaMemcpy(&sum, sum_d, sizeof(float), cudaMemcpyDeviceToHost));

        CUDA_CHECK(cudaFree(nums_d));
        CUDA_CHECK(cudaFree(sum_d));

        return sum;
    }
}
