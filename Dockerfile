FROM ubuntu:wily
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

# Install the Ubuntu packages.
RUN apt-get update && \
    apt-get install -y \
      autoconf \
      automake \
      build-essential \
      curl \
      git \
      libcairo2-dev \
      libicu-dev \
      libjpeg-dev \
      libleptonica-dev \
      libpango1.0-dev \
      libpng12-dev \
      libtiff5-dev \
      libtool \
      python-dev \
      python-pip \
      python-setuptools \
      unzip \
      vim \
      wget \
      zlib1g-dev && \
    apt-get build-dep -y tesseract-ocr

# Install csvkit.
RUN pip install csvkit

# Set the locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# More environment variables.
ENV LD_LIBRARY_PATH /usr/local/lib
WORKDIR /home

# Download and compile tesseract 3.04.00
RUN wget -O tesseract-3.04.00.tar.gz "https://github.com/tesseract-ocr/tesseract/archive/3.04.00.tar.gz"
RUN tar xzf tesseract-3.04.00.tar.gz
RUN cd tesseract-3.04.00; ./autogen.sh; ./configure; make; make install; ldconfig; make install-langs;
RUN cd tesseract-3.04.00/training; make clean
RUN cd tesseract-3.04.00; make training; make training-install

# Download English/OSD language data, needed to run tesseract
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/eng.traineddata
RUN cp eng.traineddata /usr/local/share/tessdata/
RUN wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata
RUN cp osd.traineddata /usr/local/share/tessdata/

# Download langdata and latest training tools
RUN git clone https://github.com/tesseract-ocr/langdata.git
RUN wget -O tesseract-3.04.00/training/language-specific.sh 'https://raw.githubusercontent.com/ryanfb/tesseract/latin-language-specific/training/language-specific.sh'
RUN wget -O tesseract-3.04.00/training/tesstrain_utils.sh 'https://raw.githubusercontent.com/tesseract-ocr/tesseract/master/training/tesstrain_utils.sh'
RUN wget -O tesseract-3.04.00/training/tesstrain.sh 'https://raw.githubusercontent.com/tesseract-ocr/tesseract/master/training/tesstrain.sh'

# Download and build lat.traineddata
COPY latinocr-lat latinocr-lat/
ENV TESSDATA_PREFIX /usr/local/share/tessdata
ENV PATH /home/tesseract-3.04.00/training:$PATH
RUN cd latinocr-lat; make tesstrain-prereqs
RUN cd latinocr-lat; make
