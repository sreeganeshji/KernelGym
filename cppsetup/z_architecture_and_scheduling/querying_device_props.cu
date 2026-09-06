#include <print>

int main(){
    using namespace std;
    println("hello from cuda");

    int count;
    cudaGetDeviceCount(&count);
    println("Devicecount: {}", count);

    cudaDeviceProp devProp;
    cudaGetDeviceProperties(&devProp, 0);

    println("maxBlocksPerMultiProcessor: {}", devProp.maxBlocksPerMultiProcessor);
    println("maxGridSize: {}", devProp.maxGridSize);
    println("maxThreadsDim: {}", devProp.maxThreadsDim);
    println("name: {}", devProp.name);
println("major: {}", devProp.major);
println("minor: {}", devProp.minor);

println("multiProcessorCount: {}", devProp.multiProcessorCount);
println("warpSize: {}", devProp.warpSize);
println("maxBlocksPerMultiProcessor: {}", devProp.maxBlocksPerMultiProcessor);
println("maxThreadsPerMultiProcessor: {}", devProp.maxThreadsPerMultiProcessor);
println("maxThreadsPerBlock: {}", devProp.maxThreadsPerBlock);

println("maxThreadsDim: [{}, {}, {}]",
        devProp.maxThreadsDim[0],
        devProp.maxThreadsDim[1],
        devProp.maxThreadsDim[2]);

println("maxGridSize: [{}, {}, {}]",
        devProp.maxGridSize[0],
        devProp.maxGridSize[1],
        devProp.maxGridSize[2]);

println("totalGlobalMem: {}", devProp.totalGlobalMem);
println("totalConstMem: {}", devProp.totalConstMem);
println("sharedMemPerBlock: {}", devProp.sharedMemPerBlock);
println("sharedMemPerBlockOptin: {}", devProp.sharedMemPerBlockOptin);
println("sharedMemPerMultiprocessor: {}", devProp.sharedMemPerMultiprocessor);
println("reservedSharedMemPerBlock: {}", devProp.reservedSharedMemPerBlock);

println("regsPerBlock: {}", devProp.regsPerBlock);
println("regsPerMultiprocessor: {}", devProp.regsPerMultiprocessor);
println("l2CacheSize: {}", devProp.l2CacheSize);
println("persistingL2CacheMaxSize: {}", devProp.persistingL2CacheMaxSize);
println("memoryBusWidth: {}", devProp.memoryBusWidth);
println("memPitch: {}", devProp.memPitch);

println("concurrentKernels: {}", devProp.concurrentKernels);
println("asyncEngineCount: {}", devProp.asyncEngineCount);
println("cooperativeLaunch: {}", devProp.cooperativeLaunch);
println("streamPrioritiesSupported: {}", devProp.streamPrioritiesSupported);

println("unifiedAddressing: {}", devProp.unifiedAddressing);
println("managedMemory: {}", devProp.managedMemory);
println("concurrentManagedAccess: {}", devProp.concurrentManagedAccess);
println("canMapHostMemory: {}", devProp.canMapHostMemory);
println("memoryPoolsSupported: {}", devProp.memoryPoolsSupported);

println("ECCEnabled: {}", devProp.ECCEnabled);
println("integrated: {}", devProp.integrated);
println("pciBusID: {}", devProp.pciBusID);
println("pciDeviceID: {}", devProp.pciDeviceID);
println("pciDomainID: {}", devProp.pciDomainID);

    return 0;
}