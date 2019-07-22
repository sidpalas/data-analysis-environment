# data-analysis-environment

## The goal

Establish a standard data analysis environment with the ability to easily leverage cloud computing resources (including high end GPUs) when necessary.

I prefer to do data analysis in Jupyter Notebooks, so connecting to a notebook be the end result of each step in the progression. What differs between each step is how the notebook is set up and/or what hardware it is running on.

These were all tested on MacOS 10.14.

## The progression:

### Local

 1. Local Installation: Notebook server is installed locally using the system version of Python.
 2. Inside of virtual environment: Notebook server is installed inside of a python virtual environment. For most projects, this is the setup I would use.
 3. Inside a Docker Container: Notebook server is installed inside of a Docker Container. This is mostly just a building block to make deploying to GCP easier.

### Google Cloud Platform

 4. On GCP, in a Compute Engine Virtual Machine: The same container image from above is use, but is now deployed to a Compute Engine VM.
 5. On GCP, in a Kubernetes Cluster (with an autoscaling nodepool)

 TODO:
 - With Helm or Kustomize
 - Using Cloud Deployment Manager

## The Why

Having a standard environment with which to begin analysis lowers the activation energy for getting started. For an individual, step 5 isn't entirely practical, but I wanted to increase my familiarity with Kubernetes and GCP infrastructure + tools.

## Existing Jupyter Dockerfiles
 - [DockerHub](https://hub.docker.com/u/jupyter)

## Alternatives
 - [Google Colab](https://colab.research.google.com)
 - [Google Cloud Datalab](https://cloud.google.com/datalab/)
 - [Azure Notebooks](https://notebooks.azure.com/)
 - [Crestle.ai](https://www.crestle.ai/)
