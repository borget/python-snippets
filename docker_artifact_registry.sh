#!/bin/bash -e

image_name=my-image
image_tag=0.1.0.dev
artifact_registry_uri=us-central1-docker.pkg.dev
project_id=dev-env-0884
artifact_repo=dev-container-registry

full_image_name=${image_name}:${image_tag}
artifact_registry_path=${artifact_registry_uri}/${project_id}/${artifact_repo}/${full_image_name}

echo ""
GCP_CREDS="${HOME}/.config/gcloud/application_default_credentials.json"
if [ "$1" == "" ]; then
   echo "    Using credentials found at this location: ${GCP_CREDS}. To override: build-docker.sh {credential-file}"
fi

cd "$(dirname "$0")"

gcloud auth configure-docker ${artifact_registry_uri}
docker build -t "$full_image_name" --secret id=gcp-creds,src="${GCP_CREDS}" .
docker tag "$full_image_name" ${artifact_registry_path}

docker push ${artifact_registry_path}
