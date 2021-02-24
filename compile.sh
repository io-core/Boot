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
OBERONBLDSRC=/opt/oberon/io/root/src/github.com/io-core/Build/
OBERONHALSRC=/opt/oberon/io/root/src/github.com/io-core/Boot/

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

        rm ./build/x[987].txt
	cp ./Startup.Job ./build/
	cp ./Build.Tool  ./build/
	cp ./Port.Tool   ./build/
	cp ./System.Tool ./build/

	cp ${OBERONHALSRC}HAL.*.Mod ./build/

	cp ${OBERONBLDSRC}OXP.Mod ./build/
	cp ${OBERONBLDSRC}OXP.Mod ./build/
	cp ${OBERONBLDSRC}OXG.Mod ./build/
	cp ${OBERONBLDSRC}OXX.Mod ./build/
	cp ${OBERONBLDSRC}OXB.Mod ./build/
	cp ${OBERONBLDSRC}OXS.Mod ./build/
                       
	cp ${OBERONBLDSRC}ORLinker.Mod ./build/

	cp ${OBERONBLDSRC}OXTool.Mod ./build/
	cp ${OBERONBLDSRC}O.Dis.Mod ./build/
#	cp ${OBERONBLDSRC}ORDis.Mod ./build/
#	cp ${OBERONBLDSRC}OIDis.Mod ./build/
#	cp ${OBERONBLDSRC}OaDis.Mod ./build/
#	cp ${OBERONBLDSRC}OADis.Mod ./build/
#	cp ${OBERONBLDSRC}OvDis.Mod ./build/


	mkdir -p ./result
	rm -rf ./result/*
	rm ./work.img
	${OXFSTOOL} -f2o -i build -o ./work.img -s 8M
	${EMULATOR} --mem 8 --size 1600x900x1 ./work.img
	${OXFSTOOL} -o2f -i ./work.img -o result

	mv result/HAL.rsc bin/Core.rsc
	mv result/Core.* bin/

#	rm -rf result
#	rm -rf build
#	rm work.img
  fi

fi
