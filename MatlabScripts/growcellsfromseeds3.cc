#include "mex.h"
#include "utilah.h"


typedef struct
{
  int x;
  int y;
}pix;



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

 matx *A, *B;
 matx *pixel_list;
 int mrows, ncols;
 int n,x,y,count, no_pixels1, no_pixels2, i;
 double level, celllevel, maxval;
 double *img;
 pix* pixlist;
 pix* pixlist2;
 pix* tmp;
 double cellID;
 

 // --- testing input and output values ---
 if (nrhs != 2) { mexErrMsgTxt(" usage: B=growcellsfromseeds2(CellImage with seeds at 255, celllevel)"); }
 if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
     mexErrMsgTxt("Image input must be a double real matrix");
 if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]))
     mexErrMsgTxt("Image input must be a double real matrix");

 // -- initialising arrays and stuff ---
 mrows = mxGetM(prhs[0]);
 ncols = mxGetN(prhs[0]);
 A=mx_from_vector( mxGetPr(prhs[0]), mrows, ncols);

 img=mxGetPr(prhs[0]);

 celllevel = mxGetScalar( prhs[1]);
 

 plhs[0] = mxCreateDoubleMatrix( mrows,ncols, mxREAL);
 B=mx_from_vector( mxGetPr(plhs[0]), mrows, ncols);
 
 // estimate number of pixels per image for the pixellist
 // find the max value

 no_pixels1=0;
 maxval=0;

 for (n=0; n < mrows*ncols; n++)
 {
    if (img[n] > celllevel) no_pixels1++;
    if (img[n] > maxval) maxval=img[n];
 } 

 // creating initial pixel list

 pixlist = (pix*)malloc(20*mrows*ncols*sizeof(pix));
 pixlist2 = (pix*)malloc(20*mrows*ncols*sizeof(pix));
 
 n=1;

 // initial populating pixlist and label matrix B
 // pixlist will just contains the seed points
 for (y=0; y < A->rows; y++)
  for (x=0; x < A->cols; x++)
  {
    if (A->rptr[x][y] > celllevel)
    {
      pixlist[n].x=x; pixlist[n].y=y;
      B->rptr[x][y]=n; n++;
    }
    else B->rptr[x][y]=0;
  }
   


for (level=1; level < maxval; level=level+0.05) //maxval
{
   no_pixels2=0;

   // growing cells

   //if (no_pixels1<mrows*ncols) 
   {
					
   for (n=0; n < no_pixels1; n++)
    {
        x=pixlist[n].x;  y=pixlist[n].y;
        pixlist2[no_pixels2].x=x; pixlist2[no_pixels2].y=y; no_pixels2++;
        cellID=B->rptr[x][y];
        

	// Are we touching another cell? If yes stop growing

	if(x < ncols-1 && B->rptr[x+1][y] > 0 && B->rptr[x+1][y] != cellID) { continue; }
	if(x > 0 && B->rptr[x-1][y] > 0 && B->rptr[x-1][y] != cellID) { continue; }
	if(y > 0 && B->rptr[x][y-1] > 0 && B->rptr[x][y-1] != cellID) { continue; }
	if(y < mrows-1 && B->rptr[x][y+1] > 0 && B->rptr[x][y+1] != cellID) { continue; }


	// trying to grow  
         
	if(x < ncols-1 && B->rptr[x+1][y] < 1 && A->rptr[x+1][y] < level) 
           {  B->rptr[x+1][y]=B->rptr[x][y]; pixlist2[no_pixels2].x=x+1; pixlist2[no_pixels2].y=y; no_pixels2++; }
         if(x >  0 && B->rptr[x-1][y] < 1 && A->rptr[x-1][y] < level) 
            { B->rptr[x-1][y]=B->rptr[x][y]; pixlist2[no_pixels2].x=x-1; pixlist2[no_pixels2].y=y; no_pixels2++; }
         if(y >  0 && B->rptr[x][y-1] < 1 && A->rptr[x][y-1] < level) 
            { B->rptr[x][y-1]=B->rptr[x][y]; pixlist2[no_pixels2].x=x; pixlist2[no_pixels2].y=y-1; no_pixels2++; }
         if(y < mrows-1 && B->rptr[x][y+1] < 1 && A->rptr[x][y+1] < level) 
             {B->rptr[x][y+1]=B->rptr[x][y]; pixlist2[no_pixels2].x=x; pixlist2[no_pixels2].y=y+1; no_pixels2++; }

	}
 
     }
  
      //printf("nopixels1 %d and nopixel2s %d\n",no_pixels1, no_pixels2);
  

    // populating pixellist from old pixellist with allocated pixels only
       no_pixels1 =0;
        
    	for (n=0; n < no_pixels2; n++)
    	{
          x=pixlist2[n].x;  y=pixlist2[n].y;
          if (B->rptr[x][y] > 0)
	  {
      	  pixlist[no_pixels1].x=x;
          pixlist[no_pixels1].y=y;
          no_pixels1++;
          }

	} 
 }

  free( pixlist); free( pixlist2);
  mx_free( A); mx_free(B);
}
