# Build with macOS/cpu

- Use system default Python.framework
- Use Accelerate.framework (instead of openblas)
- Use Homebrew

## Install library from homebrew-core

```
brew install snappy leveldb gflags glog szip lmdb
```

## Install library from homebrew-science

```
brew tap homebrew/science
brew install hdf5 opencv
```

## Make caffe for cpu

Use this branch's `Makefile` and `Makefile.config`

```
make -j$(sysctl -n hw.ncpu) all
make test
make runtest
```

## Make macOS bundle application

```
cd ${CAFFE_ROOT}/ideetools/macos
./aggregate_dependencies.sh
open ./example/CaffeExample.xcodeproj
```

The script named `aggregate_dependencies.sh` makes directory `${CAFFE_ROOT}/build/macos` and aggregate dependencies into it.

Xcode project setting:

- All `${CAFFE_ROOT}/build/macos/lib` libraries add to project.
- Add `Accelerate.framework` to project.
- `HEADER_SEARCH_PATHS` set to `${CAFFE_ROOT}/build/macos/include`.
- `LIBRARY_SEARCH_PATHS` set to `${CAFFE_ROOT}/build/macos/lib`.
- `GCC_PREPROCESSOR_DEFINITIONS` set `CPU_ONLY` and `USE_ACCELERATE`.
- All linked libraries are pushed into `Copy Files` phase that is destination `Frameworks` in `Build Phaeses`.

