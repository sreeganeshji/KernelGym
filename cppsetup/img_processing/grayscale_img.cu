#define NUMCHANNELS 3;

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