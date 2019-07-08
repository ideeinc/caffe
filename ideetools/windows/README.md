# Build Caffe in Windows using CPU (including Python Dependencies)

## Requirements

* Visual Studio 2013 or 2015  (other versions are not support yet)
* [CMake](https://cmake.org/) 3.4 or higher (Visual Studio and [Ninja](https://ninja-build.org/) generators are supported)
* [Anaconda](https://www.continuum.io/downloads) or [Miniconda](https://conda.io/miniconda.html) Python 2.7 or 3.5 (other versions are not supported yet)
* [MinGW](http://www.mingw.org/) or [CygWin](https://www.cygwin.com/) for C- and C++-Compiler Support (other environments haven't been tested yet)

**Note: Assure that cmake.exe and python.exe are on your PATH.**

## Configuring and Building Caffe

The fastest method to get started with caffe on Windows is by executing the following commands in a ```cmd``` prompt (we use ```C:\Projects``` as a root folder for the remainder of the instructions):

```
C:\Projects> git clone https://github.com/BVLC/caffe.git
C:\Projects> cd caffe
C:\Projects\caffe> git checkout windows
```

Before really start building Caffe, we need to setup a couple of options inside the ```build_win.cmd``` in the ```caffe/scripts``` folder in order to suit our requirements.

- setup the Python Miniconda/Anaconda path according to the system's installation path, such as ```set CONDA_ROOT=C:\Miniconda2-x64``` for version 2.7. or ```set CONDA_ROOT=C:\Miniconda3-x64``` for version 3.5 (of course, your installation path may be a different one)
- If you want to use the Ninja Generator, change the option ```set WITH_NINJA=1```. To install Ninja you can download the executable from github or install it via conda (go to the Miniconda/Anaconda main folder in order to use the **conda** command):

        ```
        > conda config --add channels conda-forge
        > conda install ninja --yes
        ```

- Lastly, set the option ```set CPU_ONLY=0``` as we use the CPU and not the GPU/CUDA

Now you can start build Caffe by executing the following command in the command prompt window:

```
C:\Projects\caffe> scripts\build_win.cmd
```

The ```build_win.cmd``` script  creates a ```build``` folder inside the ```caffe``` parent folder and puts the built files inside there. It will also download the dependencies (the location by default is: ```C:\Users\<username>\.caffe```), creates the Visual Studio project files (or the ninja build files) and builds the Release configuration. <br />
By default all the required DLLs will be copied (or hard linked when possible) next to the consuming binaries. If you wish to disable this option, you can by changing the command line option ```-DCOPY_PREREQUISITES=0```. The prebuilt libraries also provide a ```prependpath.bat``` batch script that can temporarily modify your ```PATH``` envrionment variable to make the required DLLs available.

## Troubleshooting

### Missing Compilers

If the builder complains about missing C and C++ compilers, then you need to add the following lines in the ```CMakeList.txt``` (Here we used MinGW. If you use another environment, please change the pathes accordingly) such as:

```
# ---[ Compiler
SET(CMAKE_C_COMPILER C:/MinGW/bin/gcc)
SET(CMAKE_CXX_COMPILER C:/MinGW/bin/g++)
```

### No matching Boost Version

If the required version of **Boost** according to the build_win.cmd builder output doesn't match, then the passed value in the ```find_package()``` method in the file ```Dependencies.cmake`` in the folder '''caffe/cmake``` needs to be updated accordiungly.

## Compiling Caffe

When the Windows build has been completed successfully, the built project inside the ```build``` folder needs to be compiled, for example by using Microsoft's Visual Studio. The ```build``` folder contains various project files. The fastest way to compile all Caffe project related files at once is to compile the project called ```ALL_BUILD.vcxproj```. After compilation that Caffe is ready to use. 

## Testing Caffe

### Unit Test

In order to verify that everything has been built and compiled correctly, there is another project available to test whether Caffe works properly or not. In order to initiate the test, just compile and run the project called ```runtest.vcxproj```. It will run through more than 1100 tests. If all tests have been passed successfully, then you know that Caffee works properly on your system. If one or more test failed, then please check the output error messages and validate one more time, whether you have setup everything correctly.

### MNIST based test

Another way to test Caffe is to start a program for classifying 50000 images with handwritten digits from MNIST.

At first, switch to the ```caffe```-directory and execute the following shell commands:

```
sh data/mnist/get_mnist.sh
sh examples/mnist/create_mnist.sh
```

If your have encountered an error, it might be because of a wrong path that is set inside the shell script there. In case the project has been compiled with Visual Studio, it creates (depending on your setting) a ```Debug``` or a ```Release``` folder for its compiled binaries. Since the shell scripts are not configured for that, you manually need to update the paths there, otherwise the script stops working and throws an error.<br />
Instead of using shell-scripts (.sh) you can also use powershell-scripts (.ps1) using the command prompt tool Git Shell for Windows (ot any other tool which understand PowerShell). If an error occures here as well, it might be because of the wrong pathsm, too. Please update them accordingly.

Lastly, in the ```caffe``` directory execute the following command to start Caffe's digit classification:

```
sh examples/mnist/train_lenet.sh
```

Now the digit classification program should be running and showing the various about information such as classification accuracy, loss etc.