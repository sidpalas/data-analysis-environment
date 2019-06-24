autoscaling nodepool...

gcloud container node-pools create n1-standard-4-nodepool \
    --project=$PROJECT \
    --zone=us-central1-a \
    --cluster=data-analysis-cluster \
    --disk-type=pd-standard \
    --disk-size=20 \
    --image-type=COS \
    --machine-type=n1-standard-4 \
    --num-nodes=0 \
    --enable-autoscaling \
    --min-nodes=0 \
    --max-nodes=1 \
    --service-account=$NODE_SA_EMAIL \
    --enable-autoupgrade \
    --enable-autorepair \
    --preemptible  


To ensure node gets autoscaled to zero after finishing...
kubectl drain NODE_NAME

gcloud container node-pools delete n1-standard-4-nodepool \
    --project=$PROJECT \
    --zone=us-central1-a \
    --cluster=data-analysis-cluster
