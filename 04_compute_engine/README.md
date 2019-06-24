Create GCP account

Create a billing account if you don't have one set up

Use the preemptible option to save

enable container registry api

`gcloud auth configure-docker`

`docker tag jupyter-container  gcr.io/jupyter-244404/jupyter-container:latest`

`docker push gcr.io/jupyter-244404/jupyter-container:latest`


---

```gcloud compute instances create-with-container test-instance-1 \
    --project=jupyter-244404 \
    --zone=us-central1-c \
    --container-image=gcr.io/jupyter-244404/jupyter-container \
    --machine-type=f1-micro \
    --preemptible \
    --container-mount-host-path mount-path=/home/notebooks,host-path=/home/notebooks \
    --metadata startup-script=./startup.sh
```

Wait a bit... container takes about a minute to initialize

---

`gcloud compute ssh --project=jupyter-244404 --zone=us-central1-c test-instance-1 -- 'docker ps'`

`gcloud compute ssh --project=jupyter-244404 --zone=us-central1-c test-instance-1 --container=1d28bb75cd6a -- -L 8888:localhost:8888`

`jupyter notebook list`

---

`gcloud compute instances delete test-instance-1 --project=jupyter-244404 --zone=us-central1-c`
