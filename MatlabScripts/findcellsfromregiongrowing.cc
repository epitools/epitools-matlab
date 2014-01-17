#include "mex.h"
#include "utilah.h"


typedef struct
{
  int x;
  int y;
  int l; // label 

}pix;


// growing all existing cells
void growingCells(matx* A, matx* B, int* cellsizes)
{
   int mrows=B->rows;
   int ncols=B->cols;
   int n,x,y;
   int no_pixels=0;
	
   pix* pixlist = (pix*)malloc(ncols*mrows*sizeof(pix));


   for (y=0; y < A->rows; y++)
    for (x=0; x < A->cols; x++)
    {
         if (B->rptr[x][y] == 1.0)  // find an unallocated pixel and try to assign it to a cell region
	 {
 	 	if(x < ncols-1 && B->rptr[x+1][y] > 1) 
		 	{ pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x+1][y]; no_pixels++; continue; }
         	if(x >  0 && B->rptr[x-1][y] > 1) 
			{ pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x-1][y]; no_pixels++; continue; }
         	if(y >  0 && B->rptr[x][y-1] > 1) 
			{ pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x][y-1]; no_pixels++; continue; }
         	if(y < mrows-1 && B->rptr[x][y+1] > 1) 
			{ pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x][y+1]; no_pixels++; continue; }
	 }    
    }


  for (n=0; n < no_pixels; n++)
  {
    B->rptr[pixlist[n].x][pixlist[n].y]=pixlist[n].l;
    cellsizes[ pixlist[n].l]++;
  }

 free( pixlist);
}



// search for small area in vicinity
int findingNewCells(matx* A, matx* B, int no_cells)
{
   
  int x, y, x2, y2;
  int no_pixels=0;
 
  
  for (y2=3; y2 < A->rows-3; y2++)
    for (x2=3; x2 < A->cols-3; x2++)
    {
        no_pixels=0;
        for (y=-2; y <= 2; y++)
         for (x=-2; x <= 2; x++)
	 {
  	    if (B->rptr[x2+x][y2+y] == 1.0) no_pixels++;

	 }
	// found a new cell when the area consists of more than 20 pixels
	if (no_pixels > 10)
	{
          no_cells++;
          for (y=-2; y <= 2; y++)
           for (x=-2; x <= 2; x++)
	   {
             // mark the new cell on the label matrix
  	     B->rptr[x2+x][y2+y] = no_cells;
	   }
	}
    }


 return no_cells;
}


// merge cell1 and cell2 which becomes cell2
void mergeTwoCells( matx* B, int* cellsizes, int cell1, int cell2)
{

int x,y;
int counter=0;
int label1;

for (y=0; y < B->rows; y++)
    for (x=0; x < B->cols; x++)
    {
       label1=B->rptr[x][y];
       if (label1 == cell1) { B->rptr[x][y]=cell2; counter++; }

    }

    cellsizes[cell2]=cellsizes[cell2]+counter; 
    cellsizes[cell1]=0; 
}


void mergeCells(matx* B, int* cellsizes, double mincellsize, bool belowthreshold)
{
 int x,y;
 int label1,label2;

 for (y=1; y < B->rows-1; y++)
    for (x=1; x < B->cols-1; x++)
    {
       label1=B->rptr[x][y];
       // two cells are touching
       label2=B->rptr[x+1][y];

       if (label1 > 1 && label2 > 1 && label1 != label2)
	{
            if ((cellsizes[label1] < mincellsize || cellsizes[label2] < mincellsize) || belowthreshold)
	    {
               // merging two cells
 	       mergeTwoCells( B, cellsizes, label2, label1); 
	    }
	}

	label2=B->rptr[x][y+1];
	if (label1 > 1 && label2 > 1 && label1 != label2)
	{
            if ((cellsizes[label1] < mincellsize && cellsizes[label2] < mincellsize) || belowthreshold)
	    {
               // merging two cells
 	       mergeTwoCells( B, cellsizes, label2, label1); 
	    }
	}


     }

}





void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

 matx *A, *B;
 matx *pixel_list;
 int mrows, ncols;
 int n,x,y,count, no_pixels, no_cells, i;
 double mincellsize,level, maxval, threshold;
 double *img;
 int* cellsizes;


 // --- testing input and output values ---
 if (nrhs != 3) { mexErrMsgTxt(" usage: B=regionlabel2dark(CellImage(A), max cell size, threshold)"); }
 if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
     mexErrMsgTxt("Image input must be a double real matrix");
 if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]))
     mexErrMsgTxt("Image input must be a double real matrix");

 // -- initialising arrays and stuff ---
 mrows = mxGetM(prhs[0]);
 ncols = mxGetN(prhs[0]);
 A=mx_from_vector( mxGetPr(prhs[0]), mrows, ncols);

 img=mxGetPr(prhs[0]);

 mincellsize = mxGetScalar( prhs[1]);
 threshold = mxGetScalar( prhs[2]);
 
 plhs[0] = mxCreateDoubleMatrix( mrows,ncols, mxREAL);
 B=mx_from_vector( mxGetPr(plhs[0]), mrows, ncols);
 
 // estimate number of pixels per image for the pixelist
 // find the max value
 cellsizes=(int*)malloc(mrows*ncols*sizeof(int));

 no_pixels=0;
 maxval=0;

 for (n=0; n < mrows*ncols; n++)
 {
    if (img[n] > maxval) maxval=img[n];
    cellsizes[n]=0;
 } 

 n=0; no_cells=1;

  // initialising label array B
 for (y=0; y < A->rows; y++)
  for (x=0; x < A->cols; x++)
  {
     B->rptr[x][y]=0.0;
    
   }
   

for (level=1; level <= maxval + 1; level=level+1) // grow regions until max intensity is reached
{
   
  for (y=0; y < A->rows; y++)
   for (x=0; x < A->cols; x++)
   {
     // identify unallocated pixels at this level which have not been assigned to a cell region
     if (A->rptr[x][y] <= level &&  A->rptr[x][y] > 0 && B->rptr[x][y] < 2) B->rptr[x][y]=1.0;
    
   }

   // growing loop for ten iterations
   for (i=0; i < 10; i++) 
   growingCells(A,B, cellsizes);

   // finding regions
   no_cells=findingNewCells(A, B, no_cells);

   mergeCells(B, cellsizes, mincellsize, (threshold > level));
       
 }
  free( cellsizes);
  mx_free( A); mx_free(B);
}
