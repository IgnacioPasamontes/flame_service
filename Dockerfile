FROM continuumio/miniconda3

LABEL base.image="continuumio/miniconda3"
LABEL software="flame"
LABEL software.version=" v0.1"
LABEL description="Modeling framework to build and manage QSAR models. Predictive modeling within the eTRANSAFE (http://etransafe.eu) project."
LABEL website="https://github.com/phi-grib/flame"
LABEL author="Ignacio Pasamontes <ignacio.pasamontes@upf.edu>"

# env vars
ENV USER=phi-grib
ENV REPO=flame
ENV BRANCH=flame_container
ENV WSBRANCH=docker
ENV WSREPO=flame_API

WORKDIR /opt

# install dependencies for graphics needed in matplotlib and other python dependencies
RUN apt-get update && \
    apt-get upgrade -y && \ 	
    apt-get install -y \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	nginx \
	supervisor \
	sqlite3 \
    libxrender-dev \
    libgl1-mesa-dev \
    nginx && \
    apt-get clean -y &&\
	pip3 install -U pip setuptools && \
   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY requirements_conda.txt .
RUN conda install -c default -c rdkit --file requirements_conda.txt
COPY requirements_pip.txt  .
RUN pip3 install -r requirements_pip.txt 

# cloning flame repo. First clone to get access to the environment.yml
# then pull with commit changes awareness to rebuild from the next layer
# and avoid instaling all the libraries every build.
ADD https://api.github.com/repos/$USER/$REPO/git/refs/heads/$BRANCH version.json
RUN git clone -b $BRANCH --single-branch https://github.com/$USER/$REPO.git &&\
    cd flame && \
    pip install .
   

# hand activate conda environment
#ENV PATH /opt/conda/envs/flame/bin:$PATH

ADD https://api.github.com/repos/$USER/$WSREPO/git/refs/heads/master version.json
RUN cd flame/ &&\
    cd /opt &&\
    git clone https://github.com/$USER/$WSREPO.git


WORKDIR /opt/flame_API/flame_api

RUN mkdir /data/
RUN cp -R /opt/flame/flame/models/ /data/
RUN mkdir /data/spaces/
RUN flame -c config -d /data
RUN ls
EXPOSE 8000

CMD [ "python", "manage.py" ,"runserver", "0.0.0.0:8000"]
