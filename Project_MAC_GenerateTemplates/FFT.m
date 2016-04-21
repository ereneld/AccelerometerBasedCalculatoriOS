//
//  FFT.m
//  GestureRecognition
//
//  Created by dogukan ibrahimoglu on 3/28/11.
//  Copyright 2011 Bogazici University. All rights reserved.
//

#import "FFT.h"
#import "GestureData.h"

//#define N                  10     // This is a power of 2 defining the length of the FFTs

@implementation FFT

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
       
    }
    
    return self;
}

void Compare(float *original, float *computed, long length);
void RealFFTUsageAndTiming();

-(void)makeDimensionReduction:(NSArray*) gestureDataArray{
    for(GestureData* tempGestureData in gestureDataArray){
        NSArray* dataArray = tempGestureData.gestureData;
        
        if (dataArray!= nil &&  [dataArray count]>0 && [(NSMutableArray*)[dataArray objectAtIndex:0] count] > 0) {
            
            NSMutableArray* xArray = [dataArray objectAtIndex:1];
            NSMutableArray* yArray = [dataArray objectAtIndex:2];
            NSMutableArray* zArray = [dataArray objectAtIndex:3];
            
            int numberOfElements = [xArray count];
            int numberOfElementsForFFT = pow(2, (int)log2(numberOfElements) + 1 ); 
            float* dataSequenceSpatialDomainX = (float *) malloc(numberOfElementsForFFT * sizeof(float));
            float* dataSequenceSpatialDomainY = (float *) malloc(numberOfElementsForFFT * sizeof(float));
            float* dataSequenceSpatialDomainZ = (float *) malloc(numberOfElementsForFFT * sizeof(float));
            
            float* dataSequenceFrequencyDomainX = (float *) malloc(numberOfElementsForFFT * sizeof(float));
            float* dataSequenceFrequencyDomainY = (float *) malloc(numberOfElementsForFFT * sizeof(float));
            float* dataSequenceFrequencyDomainZ = (float *) malloc(numberOfElementsForFFT * sizeof(float));
            
            [self prepareArraySpatialDomain:xArray andArrayToPrepare:dataSequenceSpatialDomainX];
            [self prepareArraySpatialDomain:yArray andArrayToPrepare:dataSequenceSpatialDomainY];
            [self prepareArraySpatialDomain:zArray andArrayToPrepare:dataSequenceSpatialDomainZ];
            
            RealFFTUsageAndTiming(dataSequenceSpatialDomainX, dataSequenceFrequencyDomainX, numberOfElements);
            RealFFTUsageAndTiming(dataSequenceSpatialDomainY, dataSequenceFrequencyDomainY, numberOfElements);
            RealFFTUsageAndTiming(dataSequenceSpatialDomainZ, dataSequenceFrequencyDomainZ, numberOfElements);
            
            [self prepareArrayFrequencyDomain:xArray andArrayFrequencyDomain:dataSequenceFrequencyDomainX];
            [self prepareArrayFrequencyDomain:yArray andArrayFrequencyDomain:dataSequenceFrequencyDomainY];
            [self prepareArrayFrequencyDomain:zArray andArrayFrequencyDomain:dataSequenceFrequencyDomainZ];
            
            free(dataSequenceSpatialDomainX);
            free(dataSequenceSpatialDomainY);
            free(dataSequenceSpatialDomainZ);
            free(dataSequenceFrequencyDomainX);
            free(dataSequenceFrequencyDomainY);
            free(dataSequenceFrequencyDomainZ); 
        }
    }
}

-(void)prepareArrayFrequencyDomain:(NSMutableArray*)arrayToChange andArrayFrequencyDomain:(float*) arrayFrequencyDomain{
    for (int i=0; i<[arrayToChange count]; i++) {
        [arrayToChange replaceObjectAtIndex:i withObject:[[NSNumber alloc]initWithFloat:arrayFrequencyDomain[i]]];
    }
}

-(void)prepareArraySpatialDomain:(NSMutableArray*) arrayOriginal andArrayToPrepare:(float*) arrayToPrepare{
    for (int i=0; i<[arrayOriginal count]; i++) {
        arrayToPrepare[i]=[[arrayOriginal objectAtIndex:i]floatValue];
    }
}

void Compare(float *original, float *computed, long length)
{
    int             i;
    float           error = original[0] - computed[0];
    float           max = error;
    float           min = error;
    float           mean = 0.0;
    float           sd_radicand = 0.0;
    
    for (i = 0; i < length; i++) {
        error = original[i] - computed[i];
        /* printf("%f %f %f\n", original[i], computed[i], error); */
        max = (max < error) ? error : max;
        min = (min > error) ? error : min;
        mean += (error / length);
        sd_radicand += ((error * error) / (float) length);
    }
    
    printf("Max error: %f  Min error: %f  Mean: %f  Std Dev: %f\n",
           max, min, mean, sqrt(sd_radicand));
}

void RealFFTUsageAndTiming(float* originalReal,float* obtainedReal, int numberOfElements)
{
    COMPLEX_SPLIT   A;
    FFTSetup        setupReal = NULL;
    uint32_t        log2n;
    uint32_t        n, nOver2;
    int32_t         stride;
    //float          *originalReal, *obtainedReal;
    float           scale;
    
    /* Set the size of FFT. */
    log2n = (int)log2(numberOfElements) ;
    n = numberOfElements; //1 << log2n;
    
    stride = 1;
    nOver2 = n / 2;
    
    printf("1D real FFT of length log2 ( %d ) = %d\n\n", n, log2n);
    
    /* Allocate memory for the input operands and check its availability,
     * use the vector version to get 16-byte alignment. */
    A.realp = (float *) malloc(nOver2 * sizeof(float));
    A.imagp = (float *) malloc(nOver2 * sizeof(float));
   
    if (originalReal == NULL || A.realp == NULL || A.imagp == NULL) {
        printf("\nmalloc failed to allocate memory for  the real FFT"
               "section of the sample.\n");
        exit(0);
    }
    
    /* Look at the real signal as an interleaved complex vector  by
     * casting it.  Then call the transformation function vDSP_ctoz to
     * get a split complex vector, which for a real signal, divides into
     * an even-odd configuration. */
    vDSP_ctoz((COMPLEX *) originalReal, 2, &A, 1, nOver2);
    
    /* Set up the required memory for the FFT routines and check  its
     * availability. */
    setupReal = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    if (setupReal == NULL) {
        printf("\nFFT_Setup failed to allocate enough memory  for"
               "the real FFT.\n");
        exit(0);
    }
    /* Carry out a Forward and Inverse FFT transform. */
    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_FORWARD);
    vDSP_fft_zrip(setupReal, &A, stride, log2n, FFT_INVERSE);
    
    /* Verify correctness of the results, but first scale it by  2n. */
    scale = (float) 1.0 / (2 * n);
    
    vDSP_vsmul(A.realp, 1, &scale, A.realp, 1, nOver2);
    vDSP_vsmul(A.imagp, 1, &scale, A.imagp, 1, nOver2);
    
    /* The output signal is now in a split real form.  Use the  function
     * vDSP_ztoc to get a split real vector. */
    vDSP_ztoc(&A, 1, (COMPLEX *) obtainedReal, 2, nOver2);
    
    /* Check for accuracy by looking at the inverse transform  results. */
    Compare(originalReal, obtainedReal, n);
    
    
    for (int i = 0; i < n; i++){
        printf("\nTime %d , Real: %4.4f, FFT: %4.4f", i, originalReal[i],obtainedReal[i]);
    }
    
    
    /* Free the allocated memory. */
    if(setupReal){
        vDSP_destroy_fftsetup(setupReal);
    }
    
    free(A.realp);
    free(A.imagp);
}



- (void)dealloc
{
    [super dealloc];
}

@end
