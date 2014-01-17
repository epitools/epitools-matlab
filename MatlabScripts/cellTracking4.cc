#include "mex.h"
#include <string.h>


#define MAX_TRACKS 100000

typedef struct
{
  unsigned short x;
  unsigned short y;
  unsigned short l; 	// label
  unsigned short i; 

}pix;


int tracking(unsigned char* inputMatrix, unsigned short* outputMatrix, double* trackLength, double* trackStarts, unsigned short* pTracks, double* trackStartX, double* trackStartY, int no_rows, int no_cols, int no_frames, int maxDistance)
{
   
  int n,i,m,x,y,f,f1, xp, yp;
  unsigned char*** datain;
  unsigned short*** dataout;
  unsigned short*** pTracksout;
  pix *pixlist;
  int no_pixels=0;
  unsigned short no_cells=0, cellnumber;
  bool found;
  int deltaD;
 
  pixlist = (pix*)malloc(no_rows*no_cols*sizeof(pix));

  // create 3D pointers from 1D array for input matrix
  datain = (unsigned char***) malloc(no_frames*sizeof(unsigned char**));
  i=0;
   
  for (n=0; n < no_frames; n++)
  {
     datain[n] = (unsigned char **)malloc(no_cols*sizeof(unsigned char*));
     for (m=0; m < no_cols; m++)
     {
         datain[n][m]=&inputMatrix[i];
         i=i+no_rows;
     }
  }


  // create 3D pointers from 1D array for output matrix
  dataout = (unsigned short***) malloc(no_frames*sizeof(unsigned short**));
  i=0;
  
  for (n=0; n < no_frames; n++)
  {
     dataout[n] = (unsigned short **)malloc(no_cols*sizeof(unsigned short*));
     for (m=0; m < no_cols; m++)
     {
         dataout[n][m]=&outputMatrix[i];
         i=i+no_rows;
     }
  }
  
  
  
 /* // create 3D pointers from 1D array for pTracks matrix
  
  pTracksout = (unsigned short***) malloc(MAX_TRACKS*sizeof(unsigned short**));
  i=0;
  
  for (n=0; n < MAX_TRACKS; n++)
  {
     pTracksout[n] = (unsigned short **)malloc(no_frames*sizeof(unsigned short*));
     for (m=0; m < no_frames; m++)
     {
         pTracksout[n][m]=&pTracks[i];
         i=i+2;
     }
  } */

  // create 3D pointers from 1D array for pTracks matrix
  
  pTracksout = (unsigned short***) malloc(2*sizeof(unsigned short**));
  i=0;
  
  for (n=0; n < 2; n++)
  {
     pTracksout[n] = (unsigned short **)malloc(no_frames*sizeof(unsigned short*));
     for (m=0; m < no_frames; m++)
     {
         pTracksout[n][m]=&pTracks[i];
         i=i+MAX_TRACKS;
     }
  }

  for (f=0; f < no_frames-1; f++)
  {
    no_pixels=0;  
    f1=f+1;  
    
     // populating pixlist with all cell positions
     for (y=0; y < no_rows; y++)
       for (x=0; x < no_cols; x++)
       {
         if (datain[f][x][y] >= 254)
         {
           pixlist[no_pixels].x=x; pixlist[no_pixels].y=y;
           pixlist[no_pixels].l=255; datain[f][x][y]=255;
           no_pixels++;
         }
         if (datain[f1][x][y] >= 254) datain[f1][x][y]=255;        
        }

       // performing the search for close points
       // increasing search space over time
       for (deltaD=3; deltaD <= maxDistance; deltaD++)
       {
        
        for (n=0; n < no_pixels; n++)
        { 
     
        // all unallocated positions are 255
        if (pixlist[n].l != 255) continue;
        
        xp=pixlist[n].x; yp=pixlist[n].y;
        
	// make sure we are inside image area
        if (xp > deltaD && yp > deltaD && xp < no_cols-deltaD && yp < no_rows-deltaD)
        {
         for(x=xp-deltaD; x <= xp+deltaD; x++)
          for (y=yp-deltaD; y <= yp+deltaD; y++)
          {
            
            if (datain[f1][x][y]==255)  // found unallocated position in next frame
            {
              cellnumber = dataout[f][xp][yp];
              
              if (cellnumber==0)  // new cell track found 
              {
                  no_cells++;
                  dataout[f][xp][yp]=no_cells;  // assign new cell number
		  pTracksout[0][f][no_cells-1]=xp+1;  pTracksout[1][f][no_cells-1]=yp+1;
                  cellnumber = no_cells;
                  trackStarts[ cellnumber-1]=f1; // assign frame start number to start list
		  trackLength[ cellnumber-1]=0;  // set track length to zero
		  trackStartX[ cellnumber-1]=xp+1; // x starting point of track 
		  trackStartY[ cellnumber-1]=yp+1;  // y starting point of track 
		    
              }
              trackLength[ cellnumber-1]++;
              dataout[f1][x][y]=cellnumber;
	      pTracksout[0][f1][cellnumber-1]=x+1;  pTracksout[1][f1][cellnumber-1]=y+1;
	     
              
              datain[f][xp][yp]=254; datain[f1][x][y]=254;// indicate that we have allocated this pixel
              pixlist[n].l=254;		     // indicate that we have allocated this pixel
              x=no_cols+100; y=no_rows+100;  // break out of both loops
            }
          
          }
       }
       }
     }
   
  }
  
  //printf("no cells: %u\n", no_cells);
  
  // clearing up memory

  // remove datain pointers
  for (n=0; n < no_frames; n++) free( datain[n]);
  free( datain);

  
  // remove dataout pointers
  for (n=0; n < no_frames; n++) free( dataout[n]);
  free( dataout);
  
   
  // remove dataout pointers
  for (n=0; n < 2; n++) free( pTracksout[n]);
  free( pTracksout);
  

  free( pixlist);
  
  return no_cells;
}





void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
 
 unsigned char* inputMatrix;    
 unsigned short* outputMatrix;
 double* trackLength;
 double* trackStarts;  
 double* trackStartX;
 double* trackStartY;
 
 unsigned short *pTracks;  
 
 const int  *dim_array;  // dimensions of the stack
 double maxDistance;
 int no_cells=0;
 


 


 // --- testing input and output values ---
 if (nrhs != 2) { mexErrMsgTxt(" usage: [Itracks, Ptracks, tracklength, trackstarts, trackstartX, trackstartY ]=cellTracking( I, maxDistance)"); }
 if (!mxIsUint8(prhs[0]))
     mexErrMsgTxt("Image with cell markers must be a uint8 matrix");

 inputMatrix = (unsigned char *)mxGetPr(prhs[0]);
 dim_array = mxGetDimensions(prhs[0]);

 maxDistance = mxGetScalar( prhs[1]);
 
 /* creating output array */
 plhs[0] = mxCreateNumericArray(3, dim_array, mxUINT16_CLASS, mxREAL);
 
 outputMatrix = (unsigned short *)mxGetData( plhs[0]);
 
 trackLength = (double*)malloc(dim_array[0]*dim_array[1]*sizeof(double));
 trackStarts = (double*)malloc(dim_array[0]*dim_array[1]*sizeof(double));
 trackStartX = (double*)malloc(dim_array[0]*dim_array[1]*sizeof(double));
 trackStartY = (double*)malloc(dim_array[0]*dim_array[1]*sizeof(double));
 
 
 
 const int dimArray[3]={MAX_TRACKS,dim_array[2],2};
 
 plhs[1] = mxCreateNumericArray(3, dimArray, mxUINT16_CLASS, mxREAL);
 
 pTracks = (unsigned short *)mxGetData( plhs[1]);

 no_cells=tracking( inputMatrix, outputMatrix, trackLength, trackStarts, pTracks, trackStartX, trackStartY, dim_array[0], dim_array[1], dim_array[2], (int)maxDistance);
 
 plhs[2] = mxCreateDoubleMatrix( no_cells, 1, mxREAL);
 plhs[3] = mxCreateDoubleMatrix( no_cells, 1, mxREAL);
 plhs[4] = mxCreateDoubleMatrix( no_cells, 1, mxREAL);
 plhs[5] = mxCreateDoubleMatrix( no_cells, 1, mxREAL);
 
 memcpy ( mxGetPr(plhs[2]), trackLength, no_cells*sizeof(double));
 memcpy ( mxGetPr(plhs[3]), trackStarts, no_cells*sizeof(double));
 memcpy ( mxGetPr(plhs[4]), trackStartX, no_cells*sizeof(double));
 memcpy ( mxGetPr(plhs[5]), trackStartY, no_cells*sizeof(double));
 
  
 
 free( trackLength); free( trackStarts); free( trackStartX); free( trackStartY); 
 
}
