FROM ubuntu:18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda2-2019.03-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN conda config --add channels defaults
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge

RUN conda install -y gromacs
RUN apt install -y gcc
RUN conda install -y scipy
RUN conda install -y numpy
RUN conda install -y pocl
RUN ln -s /etc/OpenCL/vendors /opt/conda/etc/OpenCL/vendors
RUN pip install matplotlib

RUN git clone https://github.com/deGrootLab/pmx pmx
RUN cd pmx && python setup.py install
RUN ln -s /pmx/pmx/scripts/cli.py /opt/conda/bin/cli.py
RUN mkdir /inout
ENV GMXLIB=/pmx/pmx/data/mutff45
RUN pip uninstall -y matplotlib
RUN python -m pip install --upgrade pip
RUN pip install matplotlib
RUN mkdir -p ~/.config/matplotlib/
RUN echo "backend: Agg" > ~/.config/matplotlib/matplotlibrc

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
