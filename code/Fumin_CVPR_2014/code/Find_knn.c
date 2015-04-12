#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "mex.h"  
#include "memory.h"

#define BIGNUM 10000000000;

void findmax(double *data, int n, double *result)
{
	double max_v = 0;
	double max_index;
	int i;
	for(i = 0; i < n; i++)
	{
		if (data[i] > max_v)
		{
			max_v = data[i];
			max_index = i;
		}
	}
	result[0] = max_v;
	result[1] = max_index;
}

double Eudistance(double *f1, double *f2, int dim)
{
	int i;
	double s = 0;
	for(i = 0; i < dim; i++)
	{
		s += (f1[i]-f2[i])*(f1[i]-f2[i]);
	}
	return s;

}

/* [label,distance] = find_knn(clusters,f,knn) */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/*Input Variables*/
	mxArray *clusters_temp;
	int  nClusters;
	int  dim;
	double *clusters;


	mxArray *features_temp;
	int nFeatures;
	double *features;

	mxArray  *knn_temp;
	int knn;
	

	/* Process Variable */
	int i,k,j;
	int dim_feature;
	double min_distance;
	double dis;
	double *f;
	double *f0;

	double max_buff[2];
	double *buf;
	int result_shift;

	/* Output Variable */
	double *label;
	double *distance;

	/* Get Input */
	clusters_temp	= prhs[0];
	dim				= mxGetM(clusters_temp);
	nClusters		= mxGetN(clusters_temp);
	clusters		= mxGetPr(clusters_temp);

	features_temp	= prhs[1];
	features		= mxGetPr(features_temp);
	dim_feature     = mxGetM(features_temp);
	nFeatures	    = mxGetN(features_temp);

	knn_temp		= prhs[2];
	knn				= mxGetScalar(knn_temp);


	/* for debug display */
	/*
	printf("%d\n",dim);
	printf("%d\n",nClusters);
	printf("%d\n",nFeatures);
	*/


	if(dim_feature != dim)
	{
		printf("the dimension of feature must be same as the dimension of the features in the clusters\n");
		return;
	}

	/* get output */
	plhs[0]		= mxCreateDoubleMatrix(knn,nFeatures,mxREAL);
	label		= mxGetPr(plhs[0]);
	plhs[1]		= mxCreateDoubleMatrix(knn,nFeatures,mxREAL);
	distance	= mxGetPr(plhs[1]);
	


	/* ------------------------------ core algorithm -----------------------*/
	
	f	= (double *)malloc(dim*sizeof(double));
	f0	= (double *)malloc(dim*sizeof(double));

	result_shift = 0;

	for(j = 0; j < nFeatures; j++)
	{
		/* extract a feature from feature stack */
		for(k = 0; k < dim; k++) f0[k] = features[k + j*dim];
		/* find knn */
		for(i = 0; i < knn; i++) distance[result_shift + i] = BIGNUM;
		max_buff[0] = BIGNUM; max_buff[1] = 0;
		for( i = 0; i < nClusters; i++)
		{
			for(k = 0; k < dim; k++) f[k] = clusters[k + i*dim]; /* can be further optimized */
			dis = Eudistance(f, f0, dim);
		
			if(dis < max_buff[0])
			{
				distance[result_shift + (int)max_buff[1]] = dis;
				label[result_shift + (int)max_buff[1]] = i + 1;
				buf = &distance[result_shift];
				findmax(buf, knn, max_buff);
			}
		}
		result_shift += knn;
		
	}
	
	free(f);
	free(f0);
}
	