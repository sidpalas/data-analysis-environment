`docker build ./ --tag jupyter-container`

`docker run -p 8888:8888 -v $PWD/notebooks:/home/notebooks jupyter-container`

single command:
```
docker run -p 8888:8888 -v $PWD/notebooks:/home/notebooks jupyter-container & \
    sleep 5 && \
    open -a "Google Chrome" $(echo http://localhost$((docker exec -it $(docker ps | grep jupyter-container | cut -d ' ' -f1) jupyter notebook list) | grep http | cut -c 15- | cut -d ' ' -f1))
```
