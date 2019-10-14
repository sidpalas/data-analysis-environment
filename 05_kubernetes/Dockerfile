FROM ubuntu:18.04

#### vscode server 

RUN apt-get update
RUN apt-get install -y wget
RUN wget https://github.com/cdr/code-server/releases/download/2.1523-vsc1.38.1/code-server2.1523-vsc1.38.1-linux-x86_64.tar.gz

RUN tar -xvf /code-server2.1523-vsc1.38.1-linux-x86_64.tar.gz

#### python + jupyter

RUN apt-get install -y \
	python3.7 \
	python3-pip

COPY ./requirements.txt /tmp
WORKDIR /tmp
RUN pip3 install -r requirements.txt
RUN mkdir /home/notebooks

#### gcs fuse

RUN apt-get install -y gnupg2 curl
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install -y gcsfuse

RUN mkdir /mnt/gcsfuse-bucket 

#### run both

COPY run_jupyter_and_vscode_servers.sh run_jupyter_and_vscode_servers.sh
RUN chmod +x ./run_jupyter_and_vscode_servers.sh

CMD ./run_jupyter_and_vscode_servers.sh
