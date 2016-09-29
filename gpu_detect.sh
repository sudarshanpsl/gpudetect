#!/bin/sh

# This script determines if cuda is installed and cuda capable GPU's are attached to the machine.
# The result of this script is that one of three files will exist:
#    1. cuda_not_detected
#    2. gpu_not_detected
#    3. gpu_detected
#
# This script returns 0 if at least one GPU is detected, and returns 1 if no GPU is detected.

cudaGpuDetect()
{
    rm -f cuda_not_detected
    rm -f gpu_not_detected
    rm -f gpu_detected
    reval=1
    echo "In Program-Sud"
    # Check if Nvidia compiler, nvcc, is found in the path
    nvccPath=`which nvcc`
    nvccDetected=`expr $? == 0`

    if [ $nvccDetected == 1 ]
    then
        # If nvcc is found, then:
        #    1. create a program that detects cuda capable GPU's
        #    2. compile the program using nvcc
        #    3. run the program and check the return value to determine if there are any cuda capable GPUs on this machine.
        echo "
            #include <cuda.h>
            #include <cuda_runtime.h>

            int main()
            {
                cudaError_t cudaError;
                int numCudaDevices;

                cudaError = cudaGetDeviceCount(&numCudaDevices);

                if(cudaError != cudaSuccess || numCudaDevices < 1)
                {
                    // GPU not detected
                    return 1;
                }

                // GPU detected
                return 0;
            }
            " > gpuDetect.cpp

	
   	 echo "In Program-Sud -compiling with nvcc"
        nvcc gpuDetect.cpp -o gpuDetect -arch=sm_35
        nvccCompiledSuccessfully=`expr $? == 0`

        if [ $nvccCompiledSuccessfully != 1 ]
        then
            echo "cuda_not_detected"
        else
            ./gpuDetect
            gpuDetected=`expr $? == 0`
            if [ $gpuDetected == 1 ]
            then
                retval=0
		echo "gpu - detected - Sud"
                touch gpu_detected
            else
		echo "cuda_not_detected sud--"
                touch gpu_not_detected
            fi
        fi

        rm gpuDetect.cpp
        rm gpuDetect
    else
        touch cuda_not_detected
    fi

    return $retval
}


cudaGpuDetect



