#include <iostream>

int main(){
    using namespace std;
    cout << "hello from cuda\n";

    int count;
    cudaGetDeviceCount(&count);
    cout << "Devicecount: " << count << '\n';

    cudaDeviceProp devProp;
    cudaGetDeviceProperties(&devProp, 0);

        cout << "name: " << devProp.name << '\n';
        cout << "major: " << devProp.major << '\n';
        cout << "minor: " << devProp.minor << '\n';

        cout << "multiProcessorCount: " << devProp.multiProcessorCount << '\n';
        cout << "warpSize: " << devProp.warpSize << '\n';
        cout << "maxBlocksPerMultiProcessor: " << devProp.maxBlocksPerMultiProcessor << '\n';
        cout << "maxThreadsPerMultiProcessor: " << devProp.maxThreadsPerMultiProcessor << '\n';
        cout << "maxThreadsPerBlock: " << devProp.maxThreadsPerBlock << '\n';

        cout << "maxThreadsDim: [" << devProp.maxThreadsDim[0] << ", "
         << devProp.maxThreadsDim[1] << ", " << devProp.maxThreadsDim[2] << "]\n";
        cout << "maxGridSize: [" << devProp.maxGridSize[0] << ", "
         << devProp.maxGridSize[1] << ", " << devProp.maxGridSize[2] << "]\n";

        cout << "totalGlobalMem: " << devProp.totalGlobalMem << '\n';
        cout << "totalConstMem: " << devProp.totalConstMem << '\n';
        cout << "sharedMemPerBlock: " << devProp.sharedMemPerBlock << '\n';
        cout << "sharedMemPerBlockOptin: " << devProp.sharedMemPerBlockOptin << '\n';
        cout << "sharedMemPerMultiprocessor: " << devProp.sharedMemPerMultiprocessor << '\n';
        cout << "reservedSharedMemPerBlock: " << devProp.reservedSharedMemPerBlock << '\n';

        cout << "regsPerBlock: " << devProp.regsPerBlock << '\n';
        cout << "regsPerMultiprocessor: " << devProp.regsPerMultiprocessor << '\n';
        cout << "l2CacheSize: " << devProp.l2CacheSize << '\n';
        cout << "persistingL2CacheMaxSize: " << devProp.persistingL2CacheMaxSize << '\n';
        cout << "memoryBusWidth: " << devProp.memoryBusWidth << '\n';
        cout << "memPitch: " << devProp.memPitch << '\n';

        cout << "concurrentKernels: " << devProp.concurrentKernels << '\n';
        cout << "asyncEngineCount: " << devProp.asyncEngineCount << '\n';
        cout << "cooperativeLaunch: " << devProp.cooperativeLaunch << '\n';
        cout << "streamPrioritiesSupported: " << devProp.streamPrioritiesSupported << '\n';

        cout << "unifiedAddressing: " << devProp.unifiedAddressing << '\n';
        cout << "managedMemory: " << devProp.managedMemory << '\n';
        cout << "concurrentManagedAccess: " << devProp.concurrentManagedAccess << '\n';
        cout << "canMapHostMemory: " << devProp.canMapHostMemory << '\n';
        cout << "memoryPoolsSupported: " << devProp.memoryPoolsSupported << '\n';

        cout << "ECCEnabled: " << devProp.ECCEnabled << '\n';
        cout << "integrated: " << devProp.integrated << '\n';
        cout << "pciBusID: " << devProp.pciBusID << '\n';
        cout << "pciDeviceID: " << devProp.pciDeviceID << '\n';
        cout << "pciDomainID: " << devProp.pciDomainID << '\n';

    return 0;
}