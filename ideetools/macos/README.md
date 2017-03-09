# Build with macOS/cpu

- Use system default Python.framework
- Use Accelerate.framework (instead of openblas)
- Use Homebrew
- Use cmake

## Install library from homebrew-core

```
brew install snappy leveldb gflags glog szip lmdb
```

## Install library from homebrew-science

```
brew tap homebrew/science
brew install hdf5 opencv
```

## Install library for python build

```
brew install --build-from-source --with-python -v protobuf
brew install --build-from-source -v boost boost-python
```

## Make caffe for cpu

Use this branch's `Makefile` and `Makefile.config`

```
mkdir ${CAFFE_ROOT}/build && cd $_
cmake -DCPU_ONLY=1 -DUSE_CUDNN=0 .. 
make -j$(sysctl -n hw.ncpu)
make runtest
```

## Make macOS bundle application

```
cd ${CAFFE_ROOT}/ideetools/macos
./aggregate_dependencies.sh
open ./example/CaffeExample.xcodeproj
```

The script named `aggregate_dependencies.sh` makes directory `${CAFFE_ROOT}/build/ideetools/macos` and aggregate its dependencies into it.

Xcode project setting:

- All `${CAFFE_ROOT}/build/ideetools/macos/lib` libraries add to project.
- Add `Accelerate.framework` to project.
- `HEADER_SEARCH_PATHS`: add `${CAFFE_ROOT}/build/ideetools/macos/include`.
- `LIBRARY_SEARCH_PATHS`: add `${CAFFE_ROOT}/build/ideetools/macos/lib`.
- `GCC_PREPROCESSOR_DEFINITIONS`: add `CPU_ONLY` and `USE_ACCELERATE`.
- `LD_RUNPATH_SEARCH_PATHS`: add `@executable_path/../Frameworks`
- All linked libraries are pushed into `Copy Files` phase that is destination `Frameworks` in `Build Phaeses`.

