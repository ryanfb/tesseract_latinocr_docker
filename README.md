tesseract_ancientgreekocr_docker
================================

A Dockerfile for building and installing Tesseract 3.03 and the training tools onto an Ubuntu image, then building `lat.traineddata` from scratch.

* Test the build with `docker build .`
* Tag the build with `docker build -t tesseract_latinocr .`
* Run the build with `docker run -t -i tesseract_latinocr /bin/bash`
