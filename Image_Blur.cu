
#include <cuda.h>
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>


#define N 1920;
#define M 1080;

void colorTogrey_BLUR(int *, int *,int,int);

// we have 3 channels corresponding to RGB
// The input image is encoded as unsigned characters [0, 255]
__global__ 
void blurKernel(int *Pin_d,  int *Pout_d_B, 
                          int width, int height, int BLUR_SIZE) {

 int Col = threadIdx.x + blockIdx.x * blockDim.x;
 int Row = threadIdx.y + blockIdx.y * blockDim.y;

   unsigned   int pixVal = 0;
   unsigned   int pixels = 0;
 
if (Col < (width) && Row < height) {

     for(int blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE+1; ++blurRow) {
     for(int blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE+1; ++blurCol) {
        int curRow = Row + blurRow;
        int curCol = Col + blurCol;
          // Verify we have a valid image pixel
        if(curRow > -1 && curRow < height && curCol > -1 && curCol < width) {
           pixVal += Pin_d[curRow * width + curCol];
           pixels++; // Keep track of number of pixels in the avg
            }
          }
        }
      // Write our new pixel value out
  	 Pout_d_B[Row * width + Col] = int(pixVal / pixels);
    }

}


int main()

{
    int n=N;int m=M; 

    int *Pin_h = (int*) malloc( sizeof(int)*n*m);

    int ind=0;
    unsigned int tmp;
    FILE *fp;
    fp=fopen("testImage_Results_RGB.txt","r");
    
    while (!feof(fp)){
        	
        	fscanf(fp,"%d",&tmp);
        	
        	Pin_h[ind]=tmp;
        	
        	ind=ind+1;
        	
            }
            
	fclose(fp);

int *Pout_h_B = (int*) malloc( sizeof(int)*n*m); //for BLUR operation

colorTogrey_BLUR ( Pin_h, Pout_h_B, n, m);

FILE *fp4;
    fp4=fopen("testImageResults_BLUR_RGB.txt","w");
    
    for (int i=0; i < m; i++){
    for (int j=0; j < n; j++){
    fprintf(fp4,"%4d ",Pout_h_B[i*n+j]);}
    fprintf(fp4,"\n");
    }
fclose(fp4);

// free the memory we allocated on the CPU
    free( Pin_h);
    free( Pout_h_B );
        
    return 0;

}



void colorTogrey_BLUR(int *Pin_h, int *Pout_h_B, int n, int m)
{

int size_in = (n *m*sizeof(int)); int size_out = (n*m*sizeof(int));
int *Pin_d; int *Pout_d_B; 
int BLUR_SIZE = 7;

// Transfer Pin_h to device memory 
    cudaMalloc((void **) &Pin_d, size_in);
    cudaMemcpy(Pin_d, Pin_h, size_in, cudaMemcpyHostToDevice);
      
     // Allocate device memory for Pout_d 
    cudaMalloc((void **) &Pout_d_B, size_out);

dim3 dimGrid(ceil(n/16), ceil(m/16), 1);
dim3 dimBlock(16,16,1);        

blurKernel<<<dimGrid,dimBlock>>>(Pin_d, Pout_d_B, n, m,BLUR_SIZE);

// Transfer Pout_d from device to host
    
cudaMemcpy(Pout_h_B, Pout_d_B, size_out, cudaMemcpyDeviceToHost);//copy Blurred Images to Host Memory
     
    
// Free device memory 
     cudaFree(Pin_d); cudaFree(Pout_d_B);
}


