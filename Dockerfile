FROM openjdk:11.0.3-jdk

RUN apt-get update
RUN apt-get install -y python3-pip

# Add requirements.txt
COPY ./requirements.txt ./requirements.txt
RUN ([ -f requirements.txt ] \
  && pip3 install --no-cache-dir -r requirements.txt \
  && rm requirements.txt) \
  || pip3 install --no-cache-dir jupyter jupyterlab

USER root

# Download IJava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

# Install kernel
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Set up user environment
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
  --gecos "Default user" \
  --uid ${NB_UID} \
  ${NB_USER}

COPY ./notebooks ${HOME}
RUN chown -R $NB_UID ${HOME}

USER ${NB_USER}

# Launch notebook server
WORKDIR ${HOME}
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
