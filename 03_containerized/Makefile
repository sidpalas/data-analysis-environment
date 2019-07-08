.PHONY: build-image
build-image:
	docker build ./ --tag jupyter-container

.PHONY: run-notebook
run-notebook:
	docker run -p 8888:8888 -v $(shell pwd)/notebooks:/home/notebooks jupyter-container & \
	sleep 5 && \
	CONTAINER_ID=$$(docker ps | grep jupyter-container | cut -d ' ' -f1); \
	TOKEN=$$(docker exec -it $$CONTAINER_ID jupyter notebook list | grep http | cut -c 15- | cut -d ' ' -f1); \
	URL=http://localhost$$TOKEN; \
	open -a "Google Chrome" $$URL

.PHONY: stop-notebook
stop-notebook:
	CONTAINER_ID=$$(docker ps | grep jupyter-container | cut -d ' ' -f1); \
	docker stop $$CONTAINER_ID
