`docker build ./ --tag jupyter-container`

`docker run -it -p 8888:8888 -v $PWD/notebooks:/home/notebooks jupyter-container`