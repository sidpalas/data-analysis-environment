create service account (https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes)


create cluster

add nodepool(s)

create deployment:

```
kubectl apply -f <DEPLOYMENT_FILE>.yaml
```



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


 To ensure node gets autoscaled to zero after finishing...
 `kubectl drain NODE_NAME --ignore-daemonsets`
