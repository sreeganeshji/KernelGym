/*

Control divergence can occur with if, else, or even with for loop with different threads having different iterations, so finishing at diferetn times.

One way to look at when this might occur is to check whether the decision condition depends on the threadid.


latency: unlike in CPUs where thread swapping incurs clock cyclems, GPU can preempt a warp and schedule a new idle one without any clock cycles.

Occupancy: Ideally we need to assign all the warps that an SM can handle. Occupancy is the ratio of no. of warps assigned to an SM/max no. of warps assignable to it.

A100 supports 32 blocks per SM. Each block can have 1024 threads, i.e. 32 warps. so 

Registers: A100 supports 65,536 registyers per SM, so to support 2048 threads, each thread can consume max of 32 registers. If they consume 64 instead, then SMs can support only 1024 threads. In such cases, compilers can perform register spilling, but this adds to the execution time as the threads need to access these spilled over locations.

Performance cliff: The concept that an incremental increase in resource consumption can drastically reduce the performace and parallelization accessible to the machine. Ex. if each thread was using 31 registers, 63,488 <65,536 hence SMs can effectively schedule blocks. Say if we added two more registers per thread, 67,584 < 65,536 hence the SM could kick off one block out of the occupancy say 3 instead of 4 making the occupancy go from 100% to 75%
*/