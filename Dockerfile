FROM ubuntu
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

# Install the Ubuntu packages.
RUN apt-get update
RUN apt-get install -y autoconf automake libtool libpng12-dev libjpeg-dev libtiff5-dev zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev libleptonica-dev
RUN apt-get build-dep -y tesseract-ocr
RUN apt-get install -y git wget vim unzip

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# More environment variables.
ENV LD_LIBRARY_PATH /usr/local/lib
WORKDIR /home

# Download and compile tesseract 3.03-rc1
RUN wget -O tesseract-3.03-rc1.tar.gz "https://drive.google.com/uc?id=0B7l10Bj_LprhSGN2bTYwemVRREU&export=download"
RUN tar xzf tesseract-3.03-rc1.tar.gz
RUN cd tesseract-3.03; ./autogen.sh; ./configure; make; make install; ldconfig; make install-langs;
RUN cd tesseract-3.03/training; make clean
RUN cd tesseract-3.03; make training; make training-install

# Download and build tlgu
RUN wget http://tlgu.carmen.gr/tlgu-1.6.zip
RUN mkdir tlgu-1.6; unzip -d tlgu-1.6 tlgu-1.6.zip
RUN cd tlgu-1.6; gcc tlgu.c -o /usr/local/bin/tlgu

# Download and build grc.traineddata
RUN git clone https://github.com/ryanfb/ancientgreekocr-grctraining.git
RUN cd ancientgreekocr-grctraining; make corpus
RUN cd ancientgreekocr-grctraining; make
RUN git clone https://github.com/ryanfb/ancientgreekocr-grc.git
RUN cd ancientgreekocr-grc; git fetch origin; git branch --track backup_site origin/backup_site; git checkout backup_site
RUN cp -v ancientgreekocr-grctraining/training_text.txt ancientgreekocr-grctraining/grc.word.txt ancientgreekocr-grctraining/grc.freq.txt ancientgreekocr-grctraining/grc.unicharambigs ancientgreekocr-grc
RUN wget https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.eng.tar.gz
RUN tar xzvf tesseract-ocr-3.02.eng.tar.gz
RUN cp tesseract-ocr/tessdata/eng.traineddata /usr/local/share/tessdata/
RUN cd ancientgreekocr-grc; make
