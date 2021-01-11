#!/bin/bash

# build.sh uses a risc5 emulator and 'oxfstool' to generate the Oberon core payload
# required by assemble.sh. The emulator must support powering off via an Oberon system command.
#
# An Oberon image containing a multi-target compiler and batch execution is also required.
#
# This script creates a new Oberon image from the base image and updated sources and a set of
# batch commands that compiles the updated sources and then commands the system to shut down.
# The new binaries are then extracted from the image for use in assemble.sh.

EMULATOR=/opt/oberon/oberon-risc-emu/risc
OXFSTOOL=/usr/bin/oxfstool
BASEIMAGE=/opt/oberon/io/images/io.img

tools="available"

if [ ! -f ${EMULATOR} ] ; then
	echo "A risc5 emulator is required and EMULATOR must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${OXFSTOOL} ] ; then
	echo "oxfstool is required and OXFSTOOL must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${BASEIMAGE} ] ; then
	echo "A risc5 Oberon base image is required and BASEIMAGE must be set correctly"
	tools="unavailable"
fi

if [ "$tools" == "available" ] ; then

  if [ ! -f ./Startup.Job ] ; then
	echo "Need a Startup.Job file to generate binaries from Oberon sources. Please provide."
  else
	echo "Building Oberon Core for supported architectures."
	mkdir -p ./build
	rm -rf ./build/*
	${OXFSTOOL} -o2f -i ${BASEIMAGE} -o ./build
	cp ./Startup.Job ./build/
	mkdir -p ./result
	rm -rf ./result/*
	rm ./work.img
	${OXFSTOOL} -f2o -i build -o ./work.img -s 8M
	${EMULATOR} --mem 8 --size 1600x900x4 ./work.img
	${OXFSTOOL} -o2f -i ./work.img -o result

	mv result/HAL.rsc ./Core.rsc
	mv result/HAL.i64 ./Core.i64
	mv result/HAL.a64 ./Core.a64
	mv result/HAL.a32 ./Core.a32
	mv result/HAL.v64 ./Core.v64
	mv result/HAL.v32 ./Core.v32

	rm -rf result
	rm -rf build
  fi

fi
