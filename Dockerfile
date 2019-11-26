FROM ubuntu:18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

#Apt's
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1  python-pip git && apt-get clean && apt-get autoremove --purge
RUN git clone https://github.com/deGrootLab/pmx pmx
RUN pip install setuptools scipy==1.1 matplotlib==2.2
RUN cd pmx && python2 setup.py install
RUN chmod ugo+rwx /pmx/pmx/scripts/cli.py && mkdir /inout && chmod ugo+rwx /inout
ENV GMXLIB=/pmx/pmx/data/mutff45
ENV PATH="/pmx/pmx/scripts:${PATH}"
RUN mkdir -p ~/.config/matplotlib/ && echo "backend: Agg" > ~/.config/matplotlib/matplotlibrc
WORKDIR /inout
CMD [ "/bin/bash" ]
