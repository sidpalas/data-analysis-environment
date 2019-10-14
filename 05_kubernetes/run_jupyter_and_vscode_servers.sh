#!/bin/bash

#### Run VS Code server

/code-server2.1523-vsc1.38.1-linux-x86_64/code-server /home &

#### RUN Jupyter Server

jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root /home