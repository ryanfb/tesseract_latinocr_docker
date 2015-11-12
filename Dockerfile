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
RUN wget -O tesseract-3.04.00/training/language-specific.sh 'https://raw.githubusercontent.com/tesseract-ocr/tesseract/master/training/language-specific.sh'
RUN wget -O tesseract-3.04.00/training/tesstrain_utils.sh 'https://raw.githubusercontent.com/tesseract-ocr/tesseract/master/training/tesstrain_utils.sh'
RUN wget -O tesseract-3.04.00/training/tesstrain.sh 'https://raw.githubusercontent.com/tesseract-ocr/tesseract/master/training/tesstrain.sh'

# Download and build lat.traineddata
COPY latinocr-lattraining latinocr-lattraining/
COPY latinocr-lat latinocr-lat/

RUN mkdir -p mylangdata/lat
RUN cp -v latinocr-lattraining/lat.unicharambigs mylangdata/lat/
RUN cp -v latinocr-lattraining/training_text.txt mylangdata/lat/lat.training_text
RUN cp -v latinocr-lattraining/lat.word.txt mylangdata/lat/lat.wordlist
RUN cp -v latinocr-lattraining/lat.freq.txt mylangdata/lat/lat.training_text.unigram_freqs
RUN cp -v latinocr-lat/lat.punc.txt mylangdata/lat/lat.punc
RUN cp -v latinocr-lat/lat.config mylangdata/lat/
RUN cat latinocr-lat/font_properties langdata/font_properties | sort -u > mylangdata/font_properties
RUN cp -v langdata/lat/lat.numbers mylangdata/lat/lat.numbers
RUN ls mylangdata/lat

RUN cd latinocr-lat; make fonts
RUN cd latinocr-lat; make Latin.xheights

RUN cat latinocr-lat/Latin.xheights langdata/Latin.xheights | sort -u > mylangdata/Latin.xheights
RUN cp -v latinocr-lat/Latin.xheights mylangdata/lat/lat.xheights

RUN cp -v latinocr-lattraining/allchars.txt latinocr-lat/
RUN cd latinocr-lat; make Latin.unicharset
RUN cp -v latinocr-lat/Latin.unicharset mylangdata/
RUN cp -v latinocr-lat/Latin.unicharset mylangdata/lat/lat.unicharset

RUN text2image --list_available_fonts --fonts_dir latinocr-lat

RUN cd tesseract-3.04.00; ./training/tesstrain.sh \
  --lang lat \
  --langdata_dir ../mylangdata \
  --tessdata_dir /usr/local/share/tessdata \
  --fontlist 'Wyld+Wyld Italic+Cardo+Cardo Bold+EB Garamond+EB Garamond Italic+GFS Bodoni+GFS Bodoni Bold+GFS Bodoni Bold Italic+GFS Bodoni Italic+GFS Didot+GFS Didot Bold+GFS Didot Bold Italic+GFS Didot Italic+IM FELL DW Pica PRO+IM FELL Double Pica PRO+IM FELL English PRO+IM FELL French Canon PRO+IM FELL Great Primer PRO+IM FELL DW Pica PRO Italic+IM FELL Double Pica PRO Italic+IM FELL English PRO Italic+IM FELL French Canon PRO Italic+IM FELL Great Primer PRO Italic' \
  --exposures -3 -2 -1 0 1 2 3 \
  --fonts_dir ../latinocr-lat

RUN ls -sh /tmp/tesstrain/tessdata

# Download and build lat.traineddata
# COPY latinocr-lattraining latinocr-lattraining/
# RUN cd latinocr-lattraining; make corpus
# RUN cd latinocr-lattraining; make
# COPY latinocr-lat latinocr-lat/
# RUN cp -v latinocr-lattraining/training_text.txt latinocr-lattraining/lat.word.txt latinocr-lattraining/lat.freq.txt latinocr-lattraining/lat.unicharambigs latinocr-lat
# 
# RUN cd latinocr-lat; make features lat.normproto lat.unicharambigs
# CMD cd latinocr-lat; make lat.traineddata
