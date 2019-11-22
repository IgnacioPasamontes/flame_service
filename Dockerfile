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

# Install dependencies for graphics needed in matplotlib and other python dependencies
RUN apt-get update && \
    apt-get upgrade -y && \ 	
    apt-get install -y \
	#nginx \
    #supervisor \
    libxrender-dev \
    libgl1-mesa-dev && \
    apt-get clean -y &&\
	#pip3 install -U setuptools && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install uwsgi
#RUN pip3 install uwsgi

# cloning flame repo. First clone to get access to the environment.yml
# then pull with commit changes awareness to rebuild from the next layer
# and avoid instaling all the libraries every build.
ADD https://api.github.com/repos/$USER/$REPO/git/refs/heads/$BRANCH version.json
RUN git clone -b $BRANCH --single-branch https://github.com/$USER/$REPO.git &&\
    cd flame
COPY environment.yml .
RUN  conda env create -f environment.yml


# hand activate conda environment
ENV PATH /opt/conda/envs/flame/bin:$PATH

ADD https://api.github.com/repos/$USER/$WSREPO/git/refs/heads/master version.json
RUN cd flame/ &&\
    pip install . &&\
    cd /opt &&\
    git clone https://github.com/$USER/$WSREPO.git


WORKDIR /opt/flame_API/flame_api

RUN mkdir /data/
RUN cp -R /opt/flame/flame/models/ /data/
RUN mkdir /data/spaces/
RUN flame -c config -d /data

# setup all the configfiles
#RUN echo "daemon off;" >> /opt/conda/envs/flame/etc/nginx/nginx.conf
COPY nginx-app.conf /opt/conda/envs/flame/etc/nginx/sites-available/default
COPY supervisor-app.conf /opt/conda/envs/flame/etc/supervisord/conf.d/
COPY uwsgi_params /opt/flame_API/
COPY uwsgi.ini /opt/flame_API/
RUN mkdir -p /opt/conda/envs/flame/var/run/nginx

WORKDIR /opt/flame_API

RUN conda install -c conda-forge nodejs 
RUN npm install -g @angular/cli

ADD https://api.github.com/repos/$USER/flameWeb/git/refs/heads/master version.json
RUN git clone https://github.com/$USER/flameWeb.git
RUN cd flameWeb
#RUN ng build --prod --base-href /flame.kh.svc/ --deploy-url /flame.kh.svc/static/ --output-hashing=none
EXPOSE 8000

#CMD ["/opt/conda/envs/flame/bin/nginx","-c","/opt/conda/envs/flame/etc/nginx/sites-available/default"]
#CMD ["/opt/conda/envs/flame/bin/uwsgi", "--ini", "/opt/flame_API/uwsgi.ini"]
CMD ["supervisord", "-n"]
#RUN python
#CMD [ "python", "manage.py" ,"runserver", "0.0.0.0:8000"]
