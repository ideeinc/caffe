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

## Conclusion

Now you should be able to build Caffe successfully.