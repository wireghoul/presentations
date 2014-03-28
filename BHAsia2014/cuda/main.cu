/******************************************************************************

Double salted md5 cracker by @Wireghoul - justanotherhacker.com
Based on CUDA cracker code by FireXware - OSSBox.com

******************************************************************************/

#define MAX_BRUTE_LENGTH 14
#define MAX_SALT_LENGTH 38
#define MAX_TOTAL (MAX_SALT_LENGTH + MAX_BRUTE_LENGTH + MAX_SALT_LENGTH)

//Performance:
#define BLOCKS 64
#define THREADS_PER_BLOCK 128
#define MD5_PER_KERNEL 200
#define OUTPUT_INTERVAL 20

__device__ __constant__ unsigned char cudaBrute[MAX_BRUTE_LENGTH];
__device__ __constant__ unsigned char cudaLeftSalt[MAX_SALT_LENGTH];
__device__ __constant__ unsigned char cudaRightSalt[MAX_SALT_LENGTH];
__device__ __constant__ unsigned char cudaCharSet[95];
__device__ unsigned char correctPass[MAX_TOTAL];

#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#include "md5.cu" //This contains our MD5 helper functions
#include "md5kernel.cu" //the CUDA thread

void checkCUDAError(const char *msg);

void ZeroFill(unsigned char* toFill, int length) {
    int i = 0; 
    for (i = 0; i < length; i++)
        toFill[i] = 0;
}

bool BruteIncrement(unsigned char* brute, int setLen, int wordLength, int incrementBy) {
    int i = 0;
    while (incrementBy > 0 && i < wordLength) {
        int add = incrementBy + brute[i];
        brute[i] = add % setLen;
        incrementBy = add / setLen;
        i++;
    }
    return incrementBy != 0; //we are done, if there is a remainder, because we have looped over the max
}

int main(int argc, char** argv) {
    if (argc != 5) {
        printf("Usage: %s hash salt1 salt2 length\n", argv[0]);
        return 1;
    }
    int wordLength = atoi(argv[4]);
    int charSetLen = 0;


    int numThreads = BLOCKS * THREADS_PER_BLOCK;

    unsigned char currentBrute[MAX_BRUTE_LENGTH];
    unsigned char leftSalt[MAX_SALT_LENGTH];
    unsigned char rightSalt[MAX_SALT_LENGTH];

    unsigned char cpuCorrectPass[MAX_TOTAL];

    ZeroFill(currentBrute, MAX_BRUTE_LENGTH);
    ZeroFill(cpuCorrectPass, MAX_TOTAL);
    ZeroFill(leftSalt, MAX_SALT_LENGTH);
    ZeroFill(rightSalt, MAX_SALT_LENGTH);

    charSetLen = 82;
    unsigned char charSet[charSetLen];
    memcpy(charSet, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.@!$%^&*()-_=+", charSetLen);

    unsigned char hash[32];
    //printf("%s %s %s", argv[0], argv[1], argv[2]);
    memcpy(hash, argv[1], 32);

    memcpy(leftSalt, argv[2], strlen(argv[2]));
    //memcpy(rightSalt, "|0|Test Reference|1.00|20110616221931", 37);
    memcpy(rightSalt, argv[3], strlen(argv[3]));

    printf("Cracking %s using salts %s$password$%s\n", hash, leftSalt, rightSalt);
    //turn the correct hash into it's four parts
    uint v1, v2, v3, v4;
    md5_to_ints(hash,&v1,&v2,&v3,&v4);

    //copy the salts to global
    cudaMemcpyToSymbol(cudaLeftSalt, &leftSalt, MAX_SALT_LENGTH, 0, cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(cudaRightSalt, &rightSalt, MAX_SALT_LENGTH, 0, cudaMemcpyHostToDevice);

    //zero the container used to hold the correct pass
    cudaMemcpyToSymbol(correctPass, &cpuCorrectPass, MAX_TOTAL, 0, cudaMemcpyHostToDevice);

    //create and copy the charset to device
    cudaMemcpyToSymbol(cudaCharSet, &charSet, charSetLen, 0, cudaMemcpyHostToDevice);

    bool finished = false;
    int ct = 0;
    do {
        cudaMemcpyToSymbol(cudaBrute, &currentBrute, MAX_BRUTE_LENGTH, 0, cudaMemcpyHostToDevice);

        //run the kernel
        dim3 dimGrid(BLOCKS);
        dim3 dimBlock(THREADS_PER_BLOCK);

        crack<<<dimGrid, dimBlock>>>(numThreads, charSetLen, wordLength, v1,v2,v3,v4);

        //get the "correct pass" and see if there really is one
        cudaMemcpyFromSymbol(&cpuCorrectPass, correctPass, MAX_TOTAL, 0, cudaMemcpyDeviceToHost);

        if (cpuCorrectPass[0] != 0) {
            printf("\n\nFOUND: ");
            int k = 0;
            while (cpuCorrectPass[k] != 0) {
                printf("%c", cpuCorrectPass[k]);
                k++;
            }
            printf("\n");
            return 0;
        }

        finished = BruteIncrement(currentBrute, charSetLen, wordLength, numThreads * MD5_PER_KERNEL);

        checkCUDAError("general");

        if (ct % OUTPUT_INTERVAL == 0) {
            printf("STATUS: %d", ct);
            //int k = 0;
            //for(k = 0; k < wordLength; k++)
            //    printf("%c",charSet[currentBrute[k]]);
            //printf("\n");
        }
        ct++;
        checkCUDAError("mehhhh");
    } while(!finished);

    return 0;
}

void checkCUDAError(const char *msg) {
    cudaError_t err = cudaGetLastError();
    if (cudaSuccess != err) {
        fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString( err) );
        exit(-1);
    }
}
