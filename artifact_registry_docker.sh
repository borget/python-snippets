#!/bin/bash -e

image_name=prism-ai
image_tag=0.1.0.dev
full_image_name=${image_name}:${image_tag}

echo ""
GCP_CREDS="${HOME}/.config/gcloud/application_default_credentials.json"
if [ "$1" == "" ]; then
   echo "    Using credentials found at this location: ${GCP_CREDS}. To override: build-docker.sh {credential-file}"
fi

cd "$(dirname "$0")"

gcloud auth configure-docker us-central1-docker.pkg.dev
docker build -t "$full_image_name" --secret id=gcp-creds,src="${GCP_CREDS}" .
docker tag "$full_image_name" us-central1-docker.pkg.dev/dev-env-0884/lumiata-docker/"${full_image_name}"

docker push us-central1-docker.pkg.dev/dev-env-0884/lumiata-docker/"${full_image_name}"
