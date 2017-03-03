#!/usr/bin/env sh
set -e

BASEDIR=`dirname $0`/../..
cd $BASEDIR
./build/tools/caffe train --solver=examples/mnist/lenet_solver.prototxt $@
