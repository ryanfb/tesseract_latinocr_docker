tesseract_ancientgreekocr_docker
================================

A Dockerfile for building and installing Tesseract 3.03 and the training tools onto an Ubuntu image, then building `grc.traineddata` from scratch.

* Test the build with `docker build .`
* Tag the build with `docker build -t tesseract_ancientgreekocr .`
* Run the build with `docker run -t -i tesseract_ancientgreekocr /bin/bash`
