
#include <cuda.h>
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>



#define N 1920;
#define M 1080;
#define CHANNELS 3;

void colorTogrey(int *, int *,int,int,int);

// we have 3 channels corresponding to RGB
// The input image is encoded as unsigned characters [0, 255]
__global__ 
void colorToGreyscaleConvertion(int *Pin_d,  int *Pout_d,
                          int width, int height) {

 int Col = threadIdx.x + blockIdx.x * blockDim.x;
 int Row = threadIdx.y + blockIdx.y * blockDim.y;
 
 if (Col < (width) && Row < height) {
    // get 1D coordinate for the grayscale image
    int greyOffset = Row*width + Col;
    // one can think of the RGB image having
    // CHANNEL times columns of the gray scale image
    int rgbOffset = greyOffset*3;
    unsigned int r = Pin_d[rgbOffset    ]; // red value for pixel
    unsigned int g = Pin_d[rgbOffset + 1]; // green value for pixel
    unsigned int b = Pin_d[rgbOffset + 2]; // blue value for pixel
    // perform the rescaling and store it
    // We multiply by floating point constants
    Pout_d[greyOffset] = 0.21f*r + 0.72f*g + 0.07f*b;
 }
}


int main()

{
    int n=N;int m=M; int c=CHANNELS;

    int *Pin_h = (int*) malloc( sizeof(int)*n*m*c);

    int ind=0;
    unsigned int tmp;
    FILE *fp;
    fp=fopen("test_image_RGB.txt","r");
    
    while (!feof(fp)){
        	
        	fscanf(fp,"%d",&tmp);
        	
        	Pin_h[ind]=tmp;
        	
        	ind=ind+1;
        	
            }
            
	fclose(fp);

int *Pout_h = (int*) malloc( sizeof(int)*n*m);

colorTogrey ( Pin_h, Pout_h, n, m, c);

FILE *fp3;
    fp3=fopen("testImage_Results_RGB.txt","w");
    
    for (int i=0; i < m; i++){
    for (int j=0; j < n; j++){
    fprintf(fp3,"%4d ",Pout_h[i*n+j]);}
    fprintf(fp3,"\n");
    }
fclose(fp3);

// free the memory we allocated on the CPU
    free( Pin_h);
    free( Pout_h );
        
    return 0;

}



void colorTogrey(int *Pin_h, int *Pout_h, int n, int m, int c)
{

int size_in = (n *m* c*sizeof(int)); int size_out = (n*m*sizeof(int));
int *Pin_d; int *Pout_d; 

// Transfer Pin_h to device memory 
    cudaMalloc((void **) &Pin_d, size_in);
    cudaMemcpy(Pin_d, Pin_h, size_in, cudaMemcpyHostToDevice);
      
     // Allocate device memory for Pout_d 
     cudaMalloc((void **) &Pout_d, size_out);

dim3 dimGrid(ceil(n/16), ceil(m/16), 1);
dim3 dimBlock(16,16,1);        

colorToGreyscaleConvertion<<<dimGrid,dimBlock>>>(Pin_d, Pout_d, n, m);

// Transfer Pout_d from device to host
     cudaMemcpy(Pout_h, Pout_d, size_out, cudaMemcpyDeviceToHost);
     
    
// Free device memory for A_d, B_d, C_d
     cudaFree(Pin_d); cudaFree(Pout_d); 

}


