PROJECT_ID:=jupyter-244404
INSTANCE_NAME:=test-instance
MACHINE_TYPE:=f1-micro

# Getting the docker image into Google Container Registry

.PHONY: configure-docker
configure-docker:
	gcloud auth configure-docker

.PHONY: tag-and-push-image
tag-and-push-image:
	docker tag jupyter-container  gcr.io/$(PROJECT_ID)/jupyter-container:latest;
	docker push gcr.io/$(PROJECT_ID)/jupyter-container:latest;

# Create and manage the compute engine instance

.PHONY: create-instance
create-instance:
	gcloud compute instances create-with-container $(INSTANCE_NAME) \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-c \
	    --container-image=gcr.io/$(PROJECT_ID)/jupyter-container \
	    --machine-type=$(MACHINE_TYPE) \
	    --boot-disk-size=15 \
	    --boot-disk-type=pd-standard \
	    --preemptible \
	    --container-mount-host-path mount-path=/home/notebooks,host-path=/home/notebooks \
	    --metadata startup-script=./startup.sh

.PHONY: start-instance
start-instance:
	gcloud compute instances start $(INSTANCE_NAME) \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-c

.PHONY: stop-instance
stop-instance:
	gcloud compute instances stop $(INSTANCE_NAME) \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-c

.PHONY: delete-instance
delete-instance:
	gcloud compute instances delete $(INSTANCE_NAME) \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-c

# Connect to the container

.PHONY: get-container-id
get-container-id:
	$(eval CONTAINER_ID:=$(shell gcloud compute ssh $(INSTANCE_NAME) --project=$(PROJECT_ID) --zone=us-central1-c -- "docker ps | grep jupyter-container | cut -d ' ' -f1"))
	$(eval TOKEN:=$(shell gcloud compute ssh $(INSTANCE_NAME) --project=$(PROJECT_ID) --zone=us-central1-c -- "docker exec -it $(CONTAINER_ID) jupyter notebook list | grep http | cut -c 15- | cut -d ' ' -f1"))

.PHONY: connect
connect: get-container-id
	open -a "Google Chrome" http://localhost$(TOKEN); \
	gcloud compute ssh --project=$(PROJECT_ID) --zone=us-central1-c test-instance --container=$(CONTAINER_ID) -- -L 8888:localhost:8888
