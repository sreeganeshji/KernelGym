#define NUMCHANNELS 3;

/*
62 * 76 * 3 = 14,136/3 = 4,712
16x16 blocks. = 256 threads per block, 

3.875x4.75

in the row, 64 threads will process 62 ip leaving two threads unused.
in the col, 80 thredas will process 76 ip leaving 4 threads in each block of the rows
*/

__global__
void RgbToGrayscale(char* Pin, char* Pout, int width, int height) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if(row < width && col < height) {
        int grayOffset = row * width + col;

        int rgbOffset = grayOffset * NUMCHANNELS;

        char r = Pin[rgbOffset];
        char g = Pin[rgbOffset + 1];
        char b = Pin[rgbOffset + 2];

        Pout[grayOffset] = 0.2f * r + 0.7f * g + 0.1f * b;
    }
}