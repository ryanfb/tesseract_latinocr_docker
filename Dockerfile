FROM ubuntu
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

# Install the Ubuntu packages.
RUN apt-get update
RUN apt-get install -y autoconf automake libtool libpng12-dev libjpeg-dev libtiff5-dev zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev libleptonica-dev build-essential
RUN apt-get build-dep -y tesseract-ocr
RUN apt-get install -y git wget vim unzip

# Install csvkit.
RUN apt-get install -y python-dev python-pip python-setuptools
RUN pip install csvkit

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

# Download English language data, needed to run tesseract
RUN wget https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.eng.tar.gz
RUN tar xzvf tesseract-ocr-3.02.eng.tar.gz
RUN cp tesseract-ocr/tessdata/eng.traineddata /usr/local/share/tessdata/

# Download and build lat.traineddata
COPY latinocr-lattraining latinocr-lattraining/
RUN cd latinocr-lattraining; make corpus
RUN cd latinocr-lattraining; make
COPY latinocr-lat latinocr-lat/
RUN cp -v latinocr-lattraining/training_text.txt latinocr-lattraining/lat.word.txt latinocr-lattraining/lat.freq.txt latinocr-lattraining/lat.unicharambigs latinocr-lat

RUN cd latinocr-lat; make features lat.normproto lat.unicharambigs
CMD cd latinocr-lat; make lat.traineddata
