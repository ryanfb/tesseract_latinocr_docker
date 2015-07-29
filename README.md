tesseract_latinocr_docker
=========================

A Dockerfile for building and installing Tesseract 3.03 and the training tools onto an Ubuntu image, then building [`lat.traineddata`](http://ryanfb.github.io/latinocr/) from scratch.

* Run `git submodule update --init --recursive` to clone the submodules
* Test the build with `docker build .`
* Tag the build with `docker build -t tesseract_latinocr .`
* Run the build with `docker run -d --name latinocr_build tesseract_latinocr` (which you can monitor with `docker attach latinocr_build`)
* Copy the finished build artifact out with `docker cp latinocr_build:/home/latinocr-lat/lat.traineddata .`
