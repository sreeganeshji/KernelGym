#include <cuda.h>
#include <vector>
#include <iostream>

#define CUDA_CHECK(call) checkCuda((call), #call, __FILE__, __LINE__)

void checkCuda(cudaError_t result, const char* expression, const char* file, int line){
    if(!(result == cudaError::cudaSuccess)) {
        std::cerr << "Caught error: " << cudaGetErrorName(result) << ": "
                  << cudaGetErrorString(result) << '\n';
        std::cerr << "Details: " << expression << ",\n file: " << file
                  << ",\n line: " << line << '\n';
    }
}

namespace reduction{

__global__
    void ReduceSumKernalSimple(float* nums, float* sum) {
        /*
        blockdim: 1024

        */

        int i = threadIdx.x;
        
        for(int s=blockDim.x; s>=1 ; s = s/2){

            if(i < s) {
                nums[i] = nums[i] + nums[i + s];

            }
                            
            __syncthreads();

        }

        if(i == 0) {
            *sum = nums[0];
        }
    }

    __global__ 
    void segmented_reduce_kernel(float* nums, float* sum) {
        int segment_offset = blockDim.x * 2 * blockIdx.x;
        int i = segment_offset + threadIdx.x;
        int t = threadIdx.x;

        __shared__ float inp_s[1024];

        inp_s[t] = nums[i] + nums[i+blockDim.x];

        for(int s=blockDim.x/2; s>=1; s = s/2) {
            __syncthreads();
            if(t<s) {
                inp_s[t] = inp_s[t] + inp_s[t+s];
            }
        }

        if(t == 0) {
            // *sum = inp_s[0];
            atomicAdd(sum, inp_s[0]);
        }
    }

    __global__
    void reduce_kernel_mem_div(float* nums, float* sum) {
        /*
        blockdim: 1024
        we fetch mem in 32 bit chunks, each thread is accessing far away location leading to divergence.
        This would mean
        */

        __shared__ float inp_s[1024];
        // For the first iter, read the mem and write to the first half of the shared_mem. 
        
        int i = threadIdx.x;
        
        inp_s[i] = nums[i] + nums[i+blockDim.x];

        __syncthreads();

        for(int s=blockDim.x/2; s>=1 ; s = s/2){

            if(i < s) {
                inp_s[i] = inp_s[i] + inp_s[i + s];

            }
                            
            __syncthreads();

        }

        if(i == 0) {
            *sum = inp_s[0];
        }
    }

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

            1024 threads per block
            N = 1024
            warp = 32
            collect sum values in alternative blocks, then every 4th, etc.
            0 : 0 + 1
            2 : 2 + 3
            ...
            1023 : 1023 + 1024

            sync
            0 : 0 + 2
            4 : 4 + 6
            8 : 8 + 10
            1021: 1021 + 1023

            sync
            ...
            0 : 0 + 512

            You could take all these indices and x 2 to reach 2048 elements.

            
        */
    //    printf("Reached the device");
        int i = blockDim.x * blockIdx.x + threadIdx.x;

        // if (i<10) printf("reached i: %d, blockId: %d, blockdim: %d \n", i, blockIdx.x, blockDim.x);
        
        for(int s=1; s <= blockDim.x/2; s *=2) {
            if((i % (2*s)) == 0) {
                nums[i] = nums[i] + nums[i+s];
            }

            __syncthreads();
        }

        // for(int s=1; s <= blockDim.x ; s*=2) {
        //     // if(i*s %2 == 0) {
        //     if(i*s + s < blockDim.x * 2) {
        //         // if (i<20) printf("threadID: %d, i:%d, s: %d, i*s: %d, i*s+s: %d \n", threadIdx.x, i, s, i*s, i*s+s);
        //         // if (i<20) ("threadID: %d, i:%d, s: %d, nums[%d]: %f, nums[%d]: %f \n", threadIdx.x, i, i*s, nums[i*s], i*s+s, nums[i*s+s]);
        //         nums[i*s] = nums[i*s] + nums[i*s+s];
        //     }
        //     __syncthreads();
        // }

        if(i==0)
        {
            *sum = nums[0];
        }
    }

    __global__
    void reduce_sum_coarse(float* nums, float* sum) {
        const int blockdim = 1024;
        __shared__ float inp_s[blockdim];
        int coarse_factor = 2;
        int i = (blockIdx.x * blockDim.x *2 * coarse_factor) + threadIdx.x;
        int t = threadIdx.x;

        inp_s[t] = nums[i];
        
        for(int c=1; c<2*coarse_factor; c++){
            inp_s[t] += nums[i+blockDim.x*c];

            if(t == 0) {
                printf("Reading index %d \n", i+blockDim.x*c);
            }
        }

        for(int s=blockDim.x/2; s >=1; s = s/2) {
            __syncthreads();
            if(t < s) {
                inp_s[t] = inp_s[t] + inp_s[t+s];
            }
        }

        if(t == 0) {
            atomicAdd(sum, inp_s[0]);
        }
    }

    __global__
    void ReduceSumKernel2(float* nums, float* sum) {
        /*
        Try to move the results to the first half of the array
        0 : 0 + 512
        1 : 1 + 513
        ..
        511: 511 + 1023

        __ sync

        0 : 0 + 256
        1 : 1 + 257
        ...
        255: 255 + 511

        __sync..

        0 : 0 + 1
        */
       int i = threadIdx.x;

        for (int s=blockDim.x / 2; s>=1; s/=2) {
            if(i < s) {
               nums[i] = nums[i] + nums[i+s]; 
            }

            __syncthreads();
        }

        *sum = nums[0];
    }

    float ReduceSum(std::vector<float> nums) {
        int maxThreadsPerBlock = 1024;
        dim3 dimGrid(max(static_cast<int>(ceil(nums.size()/(2*maxThreadsPerBlock))), 1));
        dim3 dimBlock(1024);
        
        std::cout << "Got nums of size: " << nums.size() << '\n';

        float* nums_d;
        CUDA_CHECK(cudaMalloc(&nums_d, sizeof(float)*nums.size()));
        CUDA_CHECK(cudaMemcpy(nums_d, nums.data(), sizeof(float) * nums.size(), cudaMemcpyHostToDevice));

        float sum;
        float *sum_d;
        CUDA_CHECK(cudaMalloc(&sum_d, sizeof(float)));

        // printf("Callinng with dimGrid: %d, dimBlock: %d", dimGrid, dimBlock);

        reduce_sum_coarse<<<dimGrid, dimBlock>>>(nums_d, sum_d);
        cudaDeviceSynchronize();
        CUDA_CHECK(cudaMemcpy(&sum, sum_d, sizeof(float), cudaMemcpyDeviceToHost));

        CUDA_CHECK(cudaFree(nums_d));
        CUDA_CHECK(cudaFree(sum_d));

        return sum;
    }
}
