# Google Kubernetes Engine

For an individual, using the Compute Engine setup as described in the previous step covers 99% of use cases... but what if we want to have multiple different compute environments (with different CPU and GPU needs) running all at once?! Managing the different Compute Engine instances and deploying each container separately might get annoying. Also, it seemed useful to know how to work with GKE.

### Service account

First, let's create a service account that will be used to grant access to GCP resources such as (Cloud Storage and Compute Engine) from the cluster. [Relevant GCP documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes)

```
gcloud iam service-accounts create <SERVICE_ACCOUNT_NAME> \
  --project=<PROJECT_ID>
```
Once the account has been created we can grant it the necessary roles:

```
gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member serviceAccount:<SERVICE_ACCOUNT_EMAIL> \
    --role roles/monitoring.metricWriter
gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member serviceAccount:<SERVICE_ACCOUNT_EMAIL> \
    --role roles/monitoring.viewer
gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member serviceAccount:<SERVICE_ACCOUNT_EMAIL> \
    --role roles/logging.logWriter
gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member serviceAccount:<SERVICE_ACCOUNT_EMAIL> \
    --role roles/storage.objectViewer
```

### Create Cluster

With the service account configured, we can now create the kubernetes cluster:

```
gcloud beta container clusters create <CLUSTER_NAME> \
    --project=$(PROJECT_ID) \
    --zone=us-central1-a \
    --no-enable-basic-auth \
    --cluster-version=1.12.8-gke.10 \
    --machine-type=<MACHINE_TYPE> \
    --image-type=COS \
    --disk-type=pd-standard \
    --disk-size=20 \
    --service-account=<SERVICE_ACCOUNT_EMAIL> \
    --num-nodes=1 \
    --network=projects/<PROJECT_ID>/global/networks/default \
    --subnetwork=projects/<PROJECT_ID>/regions/us-central1/subnetworks/default \
    --enable-autoupgrade \
    --enable-autorepair \
    --no-issue-client-certificate \
    --enable-ip-alias
```

### Setup Kubectl

To interact with the cluster we use a utility called kubectl. The following command will use your google credentials to configure kubectl for the newly created cluster:

```
gcloud container clusters get-credentials <CLUSTER_NAME> \
    --project=$(PROJECT_ID) \
    --zone=us-central1-a
```

### Add Autoscaling Nodepool

Because the master node will be running all the time, I used an inexpensive g1-small size for it. We can also add on an autoscaling nodepool with whatever level of compute power needed that will automatically spin up or down depending on our deployments to provide additional resources when needed.

```
gcloud container node-pools create <NODEPOOL_NAME> \
    --project=$(PROJECT_ID) \
    --zone=us-central1-a \
    --cluster=<CLUSTER_NAME> \
    --disk-type=pd-standard \
    --disk-size=20 \
    --image-type=COS \
    --machine-type=<SCALABLE_MACHINE_TYPE> \
    --num-nodes=0 \
    --enable-autoscaling \
    --min-nodes=0 \
    --max-nodes=1 \
    --service-account=<SERVICE_ACCOUNT_EMAIL> \
    --enable-autoupgrade \
    --enable-autorepair \
    --preemptible
```

### Create a Deployment

At this point the cluster exists, but nothing is actually running in it. We need to create a deployment that contains our container (we can use the same one as we have been `gcr.io/jupyter-244404/jupyter-container:latest`). I have created two deployments, one which does not have specific resource requests (./deployment-0.yaml) and one that does (./deployment-1.yaml). The first will deploy without triggering a scale-up while the second one will trigger the extra nodepool to be utilized.

To apply these deployments the following command is used:

```
kubectl apply -f <DEPLOYMENT_FILE>.yaml
```

To remove the deployment, the resource can simply be deleted:

```
kubectl delete deploment <DEPLOYMENT_NAME>
```

NOTE: If you have deleted the deployment but the autoscaling node hasn't stopped you can use the drain command to ensure the node actually gets autoscaled to zero:

```
kubectl drain NODE_NAME --ignore-daemonsets
```

### Connecting to notebook

To connect to the notebook we can first find the pod name with:

```
kubectl get pods
```

The following will show us the port and token for the notebook server:
```
kubectl exec -it <POD_ID> jupyter notebook list
```

Finally, we can forward port 8888 to our local system using:
```
kubectl port-forward <POD_ID> 8888
```
As before, the notebook server can then be accessed on localhost. These steps have been combined into a single make target that can be run with `make connect-to-notebook`.

### Look... Autoscaling!
```
Events:
  Type     Reason                  Age              From                                                          Message
  ----     ------                  ----             ----                                                          -------
  Warning  FailedScheduling        2m (x2 over 2m)  default-scheduler                                             persistentvolumeclaim "notebook-pv-claim" not found
  Normal   NotTriggerScaleUp       1m               cluster-autoscaler                                            pod didn't trigger scale-up (it wouldn't fit if a new node is added):
  Warning  FailedScheduling        1m (x5 over 2m)  default-scheduler                                             0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory.
  Normal   TriggeredScaleUp        1m               cluster-autoscaler                                            pod triggered scale-up: [{https://content.googleapis.com/compute/v1/projects/jupyter-244404/zones/us-central1-a/instanceGroups/gke-data-analysis-cl-n1-standard-4-no-86ad6e2d-grp 0->1 (max: 1)}]
  Normal   NotTriggerScaleUp       1m (x4 over 1m)  cluster-autoscaler                                            pod didn't trigger scale-up (it wouldn't fit if a new node is added): 1 max limit reached
  Normal   Scheduled               58s              default-scheduler                                             Successfully assigned default/jupyter-dcf858885-rgb4j to gke-data-analysis-cl-n1-standard-4-no-86ad6e2d-sztf
  Normal   SuccessfulAttachVolume  50s              attachdetach-controller                                       AttachVolume.Attach succeeded for volume "pvc-387d6b9a-a790-11e9-8894-42010a8000bf"
  Normal   Pulling                 39s              kubelet, gke-data-analysis-cl-n1-standard-4-no-86ad6e2d-sztf  pulling image "gcr.io/jupyter-244404/jupyter-container:latest"
  Normal   Pulled                  14s              kubelet, gke-data-analysis-cl-n1-standard-4-no-86ad6e2d-sztf  Successfully pulled image "gcr.io/jupyter-244404/jupyter-container:latest"
  Normal   Created                 7s               kubelet, gke-data-analysis-cl-n1-standard-4-no-86ad6e2d-sztf  Created container
  Normal   Started                 6s               kubelet, gke-data-analysis-cl-n1-standard-4-no-86ad6e2d-sztf  Started container
 ```
