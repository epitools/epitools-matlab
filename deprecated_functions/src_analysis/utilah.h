#include <stdio.h>
#include <math.h>

/*  --- data structures ---- */

typedef struct
{
  double** rptr; /* pointer to 2D double array */
  int rows;
  int cols;
  int newmatrix; /* indicates if data array can be delete */
} matx;


/*   ----------------  memory management functions -------- */

double** get_array( double* data, int no_rows, int no_cols)
{
  int r=0,c=0;
  double** rptr = (double**) malloc(no_cols*sizeof(double*));

  for ( c=0; c < no_cols; c++)
  {
   rptr[c] = (double*)&data[r];
   r=r+no_rows;
  }
  return rptr;
}

matx* mx_from_vector( double* data, int no_rows, int no_cols)
{
  int r=0,c=0;
  double **matP = (double**) malloc(no_cols*sizeof(double*));
  matx* m = (matx *) malloc(sizeof(matx));

  for ( c=0; c < no_cols; c++)
  {
   matP[c] = (double*)&data[r];
   r=r+no_rows;
  }

  m->cols=no_cols; m->rows=no_rows;
  m->rptr=matP; m->newmatrix=0; /* false, it is old data */
  return m;
}

matx* mx_new(int no_rows, int no_cols)
{

  double* data = (double*) malloc( no_rows*no_cols*sizeof(double));

  matx* m = mx_from_vector( data, no_rows, no_cols);
  m->newmatrix=1; /* true, it is a new matrix */

 return m;
}

void mx_free( matx* m)
{
  if (m->newmatrix == 1) free( m->rptr[0]);
  free(m->rptr); m->rptr=NULL;
  free( m); 
}

matx* mx_clone(matx* a)
{
  matx* m = mx_new( a->rows, a->cols);
  register int x,y;

  for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      m->rptr[x][y]=a->rptr[x][y];
    }
  return m;
}

/* a=b */
void mx_copy( matx* a, matx* b)
{
   register int x,y;
   if (a->rows != b->rows || a->cols != b->cols)
    {
     printf("ERROR in copy_Matx: matrix sizes must agree\n");
     return;
    }

   for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=b->rptr[x][y];
    }
}

/*  copy region of size a from (rpos and cpos) in matrix b
    rpos, cpos  denote centre of the matrix

*/

void mx_copy_region( matx* a, matx* b, int xpos, int ypos)
{
   register int x,y;
   ypos=ypos-(a->rows/2);
   xpos=xpos-(a->cols/2);

   for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=b->rptr[xpos+x][ypos+y];
    }
}


void mx_find_peak(matx* a, int* xpos, int* ypos)
{
  register int x,y;
  float max=-1000000;

   for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      if (a->rptr[x][y] > max)
      {
         *ypos=y; *xpos=x; max=a->rptr[x][y];
      }
    }
}

void mx_centroid(matx* a, int* xpos, int* ypos)
{
  register int x,y;
  double xdx=0.0, ydy=0.0, sum=0.0, val;

  for (x=0; x < a->cols; x++)
  {
    for (y=0; y < a->rows; y++)
    {
      val=a->rptr[x][y];
      xdx=xdx+(x+1)*val;
      ydy=ydy+(y+1)*val;
      sum=sum+val;
    }
  }
 if (sum==0) { *xpos=a->cols/2; *ypos=a->rows/2;}
 else
 {
   *ypos=(int)((ydy/sum)-0.5); *xpos=(int)((xdx/sum)-0.5);
 }
}


void mx_print(matx* m)
{
  int x,y;
  for (y=0; y < m->rows; y++)
  {
    for (x=0; x < m->cols; x++)
    {
      printf(" %f", (float)m->rptr[x][y]);
    }
    printf("\n");
  }
}

/* ------------   simple statistics functions ------------ */

double mx_min(matx* a)
{
  register int x,y;
  double _min=1000000.0;

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
        if (a->rptr[x][y] < _min) _min=a->rptr[x][y];
     }
 return _min;
}

double mx_max(matx* a)
{
  register int x,y;
  double _max=-1000000.0;

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
        if (a->rptr[x][y] > _max) _max=a->rptr[x][y];
     }
 return _max;
}

double mx_mean(matx* a)
{
  register int x,y;
  double sum=0.0;

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
        sum=sum+a->rptr[x][y];
     }
 return sum/(a->rows*a->cols);
}

double mx_std(matx* a)
{
  register int x,y;
  double sum=0.0;
  double m=mx_mean(a);

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
        sum=sum+((a->rptr[x][y]-m)*(a->rptr[x][y]-m));
     }
 return sqrt(sum/(a->rows*a->cols));
}


void mx_abs(matx* a)
{
 register int x,y;

  for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
      a->rptr[x][y] = fabs( a->rptr[x][y]);
}

void mx_positive(matx* a)
{
  register int x,y;

  for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
      if (a->rptr[x][y] < 0) a->rptr[x][y]=0;
}

/* normalise between 0..1 */
void mx_normalise(matx* a)
{
  register int x,y;
  double _max=mx_max(a), _min=mx_min(a);
  double s= 1/(_max-_min);

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
       a->rptr[x][y]=(a->rptr[x][y]+_min)*s;
     }
}


double mx_find(matx* a, double value)
{
  register int x,y;
  double sum=0.0;

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
        if (a->rptr[x][y]==value) sum=sum+1;
     } 
    
   return sum;     
}

void mx_clear(matx* a)
{
  register int x,y;

  for (x=0; x < a->cols; x++)
     for (y=0; y < a->rows; y++)
     {
        a->rptr[x][y]=0.0;
     }
}

/* ---- Simple Arithmatic ----------- */



/* a=a+b */
void mx_add_matrix(matx* a, matx* b)
{
  register int x,y;

  if (a->rows != b->rows || a->cols != b->cols)
   {
   printf("ERROR in add_matrix: Matrix dimensions must agree\n");
   return;
   }

  for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=a->rptr[x][y]+b->rptr[x][y];
    }
}

/* a=a+s */
void mx_add_scalar(matx* a, double s)
{
  register int x,y;

  for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=a->rptr[x][y]+s;
    }
}


/* a=a-b; */
void mx_sub_matrix(matx* a, matx* b)
{
  register int x,y;

   if (a->rows != b->rows || a->cols != b->cols)
    {
     printf("ERROR in sub_Matx: Matx sizes must agree\n");
     return;
    }

   for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=a->rptr[x][y]-b->rptr[x][y];
    }
}

/* a=a-s */
void mx_sub_scalar(matx* a, double s)
{
  register int x,y;

  for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=a->rptr[x][y]-s;
    }
}

/* a=a*s */
void mx_mult_scalar( matx* a, double s)
{
 register int x,y;

 for (x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      a->rptr[x][y]=s*a->rptr[x][y];
    }
}


/* a = corr(a,b) */
double mx_corr(matx* a, matx* b)
{
  register int x,y;
  double meanA, meanB, sumAB=0.0, sumA2=0.0, sumB2=0.0;
  
  if (a->rows != b->rows || a->cols != b->cols) return 0.0;
  
  meanA = mx_mean(a);
  meanB= mx_mean(b);
  
  for(x=0; x < a->cols; x++)
    for (y=0; y < a->rows; y++)
    {
      sumAB=sumAB+((a->rptr[x][y]-meanA)*(b->rptr[x][y]-meanB));
      sumA2=sumA2+((a->rptr[x][y]-meanA)*(a->rptr[x][y]-meanA));
      sumB2=sumB2+((b->rptr[x][y]-meanB)*(b->rptr[x][y]-meanB));
    }
   
  return sumAB/(sqrt(sumA2*sumB2));
}

