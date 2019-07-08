# Compute Engine (Google Cloud Platform)

In the previous step we ran a Jupyter notebook within a container. We can now take that container image and deploy it to a virtual machine running in the cloud (this example uses GCP).

This allows us to tap into whatever compute resources our analysis requires and pay for them with [second level precision](https://cloud.google.com/blog/products/gcp/extending-per-second-billing-in-google).

The first step is to create go to https://console.cloud.google.com/ and set up an account (or link an existing Google account).

After setting up an account, we need to push our container to Google Container Registry using the following commands:

`gcloud auth configure-docker`

`docker tag jupyter-container  gcr.io/<PROJECT_ID>/jupyter-container:latest`

`docker push gcr.io/<PROJECT_ID>/jupyter-container:latest`

<!--
```
gcloud compute disks create shared-disk \
    --project=<PROJECT_ID> \
    --zone=us-central1-c \
    --type=pd-standard \
    --size=15
```

```
gcloud compute instances attach-disk <INSTANCE_NAME> \
    --project=<PROJECT_ID> \
    --zone=us-central1-c \
    --disk=shared-disk
```

```
gcloud compute instances detach-disk <INSTANCE_NAME> \
    --project=<PROJECT_ID> \
    --zone=us-central1-c \
    --disk=shared-disk
``` -->

This container can then be used to instantiate a compute engine instance:

```
gcloud compute instances create-with-container <INSTANCE_NAME> \
    --project=<PROJECT_ID> \
    --zone=us-central1-c \
    --container-image=gcr.io/<PROJECT_ID>/jupyter-container \
    --machine-type=<MACHINE_TYPE> \
    --boot-disk-size=15 \
    --boot-disk-type=pd-standard \
    --preemptible \
    --container-mount-host-path mount-path=/home/notebooks,host-path=/mnt/disk/notebooks \
    --metadata startup-script=./startup.sh
```

TODO: Explain the configuration options...

<!-- ```
gcloud compute instances stop <INSTANCE_NAME> \
    --project=<PROJECT_ID> \
    --zone=us-central1-c \
```

```
gcloud compute instances start <INSTANCE_NAME> \
    --project=<PROJECT_ID> \
    --zone=us-central1-c \
``` -->

Once it is up and running (the instance and container takes a few minutes to be fully operational) we can use the `gcloud compute ssh` command to connect to the instance. We first run a docker ps command to get the container id:

<!-- format the disk... https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting -->


`gcloud compute ssh --project=<PROJECT_ID> --zone=us-central1-c <INSTANCE_NAME> -- 'docker ps'`

Then we can connect to the container and forward port 8888 to connect to the notebook server:

`gcloud compute ssh --project=<PROJECT_ID> --zone=us-central1-c <INSTANCE_NAME> --container=<CONTAINER_ID> -- -L 8888:localhost:8888`

Finally run `jupyter notebook list` to get the notebook token and connect.

These commands are combined into a single make target so that all it takes to connect is `make connect`.

<!-- `gcloud compute instances delete test-instance --project=<PROJECT_ID> --zone=us-central1-c` -->
