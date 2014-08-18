/*
 
 1. finding non allocated regions based on a intensity threshold
 2. finding new cells based on clustered unallocated regions
 3. grow cells with a maximum number of iterations and below the intensity threshold
 4. merge regions on the basis of cell size and cell intenity
 
 */


#include "mex.h"
#include "utilah.h"


//pixel list
typedef struct
{
    int x;
    int y;
    int l; // label
    
}pix;


// growing all existing cells (or rather, assigning newly available pixels to present regions)
void growingCells(matx* A, matx* B, int* cellsizes) //imageMatrix A, label B, cellsizes = how many pixels per cell
{
    int mrows=B->rows;
    int ncols=B->cols;
    int n,x,y;
    int no_pixels=0;
	
    pix* pixlist = (pix*)malloc(ncols*mrows*sizeof(pix));
    
    
    for (y=0; y < A->rows; y++)
    {
        for (x=0; x < A->cols; x++)
        {
            if (B->rptr[x][y] == 1.0)
            {
                //Found an available (<level) but unallocated pixel
                //=> try to assign it to a cell region
                
                //check neighborhood for possible assingnment
                if(x < ncols-1 && B->rptr[x+1][y] > 1)
                {
                    pixlist[no_pixels].x=x;
                    pixlist[no_pixels].y=y ;
                    pixlist[no_pixels].l=B->rptr[x+1][y];
                    no_pixels++;
                    continue;
                }
                if(x >  0 && B->rptr[x-1][y] > 1)
                { pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x-1][y]; no_pixels++; continue; }
                if(y >  0 && B->rptr[x][y-1] > 1)
                { pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x][y-1]; no_pixels++; continue; }
                if(y < mrows-1 && B->rptr[x][y+1] > 1)
                { pixlist[no_pixels].x=x; pixlist[no_pixels].y=y ;pixlist[no_pixels].l=B->rptr[x][y+1]; no_pixels++; continue; }
            }
        }
    }
    
    
    //Post Update of Label Matrix B (i.e. Prevent cell from growing indefinitely)
    for (n=0; n < no_pixels; n++)
    {
        B->rptr[pixlist[n].x][pixlist[n].y]=pixlist[n].l;
        cellsizes[ pixlist[n].l]++;
    }
    
    free( pixlist);
}



// search for cluster of unallocated but AVAILABLE pixels
int findingNewCells(matx* A, matx* B, int no_cells)
{
    
    int x, y, x2, y2;
    int no_pixels=0;
    
    //whole image with border
    for (y2=3; y2 < A->rows-3; y2++)
        for (x2=3; x2 < A->cols-3; x2++)
        {
            no_pixels=0;
            
            //going through rectangular region 5x5
            for (y=-2; y <= 2; y++)
                for (x=-2; x <= 2; x++)
                {
                    if (B->rptr[x2+x][y2+y] == 1.0) //i.e. only AVAILABLE pixels count!
                        no_pixels++;
                    
                }
            
            int min_cluster_size = 10;
            
            // found a new cell when the area consists of more than 10 pixels
            if (no_pixels > min_cluster_size)
            {
                no_cells++; // cell label == cell number
                for (y=-2; y <= 2; y++)
                    for (x=-2; x <= 2; x++)
                    {
                        // mark the new cell on the label matrix
                        //if (B->rptr[x2+x][y2+y] == 1.0) TODO, should be corrected with here!
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


//merge touching regions if conditions are met
void mergeCells(matx* B, int* cellsizes, double mincellsize, bool belowthreshold)
{
    int x,y;
    int label1,label2;
    
    for (y=1; y < B->rows-1; y++)
    {
        for (x=1; x < B->cols-1; x++)
        {
            // check whether two cells are touching
            label1=B->rptr[x][y];
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
    if (nrhs != 3) { mexErrMsgTxt(" usage: B=findscellsfromregiongrowing(CellImage(A), min cell size, threshold)"); }
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
        mexErrMsgTxt("Image input must be a double real matrix");
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]))
        mexErrMsgTxt("Image input must be a double real matrix");
    
    // -- initialising arrays and stuff --- //matlab to c++ conversion
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
            B->rptr[x][y]=0.0; // I.e. the pixel is UNAVAILABLE
            
        }
    
    
    // stepsize
    int step_size = 1;
    for (level=1; level <= maxval + 1; level=level+step_size) // grow regions until max intensity is reached
    {
        
        for (y=0; y < A->rows; y++)
            for (x=0; x < A->cols; x++)
            {
                // identify unallocated pixels at this level which have not been assigned to a cell region
                // i.e. only certain pixels can be 'used' at every round (=> beneath current _level_)
                if (A->rptr[x][y] <= level &&  A->rptr[x][y] > 0 && B->rptr[x][y] < 2)
                    B->rptr[x][y]=1.0; // i.e. pixel is now AVAILABLE for assignment!
                
            }
        
        // growing loop for ten iterations (i.e. the AVAILABLE pixel can be assigned to confining regions)
        int region_growing_limit = 10;
        for (i=0; i < region_growing_limit; i++)
            growingCells(A,B, cellsizes);
        
        // finding regions (AVAILABLE pixel could cluster without ever touching => lookout for new regions)
        // => This function creates the first seeding.
        no_cells=findingNewCells(A, B, no_cells);
        
        //merge regions that touch that are below minimal cell size or if the intenisity threshold
        //for small cells hasn't yet been reached.
        mergeCells(B, cellsizes, mincellsize, (threshold > level));
        
    }
    
    
    free( cellsizes);
    mx_free( A); mx_free(B);
    
}
