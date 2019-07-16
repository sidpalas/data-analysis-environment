PROJECT_ID:=jupyter-244404
SERVICE_ACCOUNT_NAME:=gke-node-sa
CLUSTER_NAME:=data-analysis-cluster
MACHINE_TYPE:=g1-small
SCALABLE_MACHINE_TYPE:=n1-standard-4

# Service account

.PHONY: get-service-account-email
get-service-account-email:
	$(eval SERVICE_ACCOUNT_EMAIL:=$(shell gcloud iam service-accounts list --project=$(PROJECT_ID) --format='value(email)' --filter='name:$(SERVICE_ACCOUNT_NAME)'))
	@echo $(SERVICE_ACCOUNT_EMAIL)

.PHONY: create-service-account
create-service-account:
	gcloud iam service-accounts create $(SERVICE_ACCOUNT_NAME) \
	  --project=$(PROJECT_ID)

.PHONY: add-service-account-roles
add-service-account-roles: get-service-account-email
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	    --member serviceAccount:$(SERVICE_ACCOUNT_EMAIL) \
	    --role roles/monitoring.metricWriter
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	    --member serviceAccount:$(SERVICE_ACCOUNT_EMAIL) \
	    --role roles/monitoring.viewer
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	    --member serviceAccount:$(SERVICE_ACCOUNT_EMAIL) \
	    --role roles/logging.logWriter
	gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	    --member serviceAccount:$(SERVICE_ACCOUNT_EMAIL) \
	    --role roles/storage.objectViewer

.PHONY: setup-service-accout
setup-service-account:
	make create-service-account
	sleep 5
	make add-service-account-roles

.PHONY: delete-service-account
delete-service-account: get-service-account-email
	gcloud iam service-accounts delete $(SERVICE_ACCOUNT_EMAIL) \
	  --project=$(PROJECT_ID)

# Cluster

.PHONY: create-cluster
create-cluster: get-service-account-email
	gcloud beta container clusters create $(CLUSTER_NAME) \
		--project=$(PROJECT_ID) \
		--zone=us-central1-a \
		--no-enable-basic-auth \
		--cluster-version=1.12.8-gke.10 \
		--machine-type=$(MACHINE_TYPE) \
		--image-type=COS \
		--disk-type=pd-standard \
		--disk-size=20 \
		--service-account=$(SERVICE_ACCOUNT_EMAIL) \
		--num-nodes=1 \
		--network=projects/$(PROJECT_ID)/global/networks/default \
		--subnetwork=projects/$(PROJECT_ID)/regions/us-central1/subnetworks/default \
		--enable-autoupgrade \
		--enable-autorepair


.PHONY: setup-kubectl
setup-kubectl:
	gcloud container clusters get-credentials $(CLUSTER_NAME) \
		--project=$(PROJECT_ID) \
		--zone=us-central1-a

.PHONY: delete-cluster
delete-cluster:
	gcloud beta container clusters delete $(CLUSTER_NAME) \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-a

# Nodepool

.PHONY: add-nodepool
add-nodepool: get-service-account-email
	gcloud container node-pools create $(SCALABLE_MACHINE_TYPE)-nodepool \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-a \
	    --cluster=$(CLUSTER_NAME) \
	    --disk-type=pd-standard \
	    --disk-size=20 \
	    --image-type=COS \
	    --machine-type=$(SCALABLE_MACHINE_TYPE) \
	    --num-nodes=0 \
	    --enable-autoscaling \
	    --min-nodes=0 \
	    --max-nodes=1 \
	    --service-account=$(SERVICE_ACCOUNT_EMAIL) \
	    --enable-autoupgrade \
	    --enable-autorepair \
	    --preemptible

.PHONY: remove-nodepool
remove-nodepool:
	gcloud container node-pools delete n1-standard-4-nodepool \
	    --project=$(PROJECT_ID) \
	    --zone=us-central1-a \
	    --cluster=$(CLUSTER_NAME)

# Notebook

.PHONY: connect-to-notebook
connect-to-notebooks:
	POD_ID=$$(kubectl get pods | grep jupyter | cut -d ' ' -f1); \
	kubectl port-forward $$POD_ID 8888 & \
	TOKEN=$$(kubectl exec -it $$POD_ID jupyter notebook list | grep http | cut -c 15- | cut -d ' ' -f1); \
	URL=http://localhost$$TOKEN; \
	open -a "Google Chrome" $$URL
