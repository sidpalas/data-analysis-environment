create service account (https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes)

export PROJECT=jupyter-244404

export NODE_SA_NAME=kubernetes-engine-node-sa
gcloud iam service-accounts create $NODE_SA_NAME \
  --project=$PROJECT \
  --display-name "GKE Node Service Account"

export NODE_SA_EMAIL=`gcloud iam service-accounts list --project=$PROJECT --format='value(email)' \
  --filter='displayName:Node Service Account'`

gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$NODE_SA_EMAIL \
    --role roles/monitoring.metricWriter
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$NODE_SA_EMAIL \
    --role roles/monitoring.viewer
gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$NODE_SA_EMAIL \
    --role roles/logging.logWriter
    gcloud projects add-iam-policy-binding $PROJECT \
        --member serviceAccount:$NODE_SA_EMAIL \
        --role roles/storage.objectViewer

In addition to the bare minimum, it also needs access to pull from container registry...

create cluster...

gcloud beta container clusters create data-analysis-cluster \
    --project=$PROJECT \
    --zone=us-central1-a \
    --no-enable-basic-auth \
    --cluster-version=1.12.8-gke.10 \
    --machine-type=g1-small \
    --image-type=COS \
    --disk-type=pd-standard \
    --disk-size=20 \
    --service-account=$NODE_SA_EMAIL \
    --num-nodes=1 \
    --network=projects/jupyter-244404/global/networks/default \
    --subnetwork=projects/jupyter-244404/regions/us-central1/subnetworks/default \
    --enable-autoupgrade \
    --enable-autorepair \
    --no-issue-client-certificate \
    --no-enable-ip-alias

gcloud components install kubectl

kubectl apply -f deployment.yaml


clean up...

gcloud beta container clusters delete data-analysis-cluster \
    --project=$PROJECT \
    --zone=us-central1-a
