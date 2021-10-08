#!/bin/bash -e

echo ""
GCP_CREDS="${HOME}/.config/gcloud/application_default_credentials.json"
if [ "$1" == "" ]; then
   echo "    Using credentials found at this location: ${GCP_CREDS}. To override: build-docker.sh {credential-file}"
fi
IMAGE_ID=cube-pipeline:local
BUILD_TIMESTAMP=$(date +%s)
echo "Building kubeflow pipelines image... WITH:"
echo "    IMAGE_ID: $IMAGE_ID"
echo "    BUILD_TIMESTAMP: $BUILD_TIMESTAMP"
echo ""
docker build -f ./Dockerfile -t $IMAGE_ID \
    --secret id=gcp-creds,src="${GCP_CREDS}" \
    --build-arg BUILD_TIMESTAMP=$BUILD_TIMESTAMP \
    .


registry="gcr.io/host-project-f966"
tag="dev"

echo " "
echo "[Docker-Build] - Build component docker images"
echo " "

docker tag cube-pipeline:local $registry/cube-pipeline:${tag}
docker push $registry/cube-pipeline:${tag}

#Output the strict image name (which contains the sha256 image digest)
#This name can be used by the subsequent steps to refer to the exact image that was built even if another image with the same name was pushed.
# image_name_with_digest=$(docker inspect --format="{{index .RepoDigests 0}}" "$IMAGE_NAME")
strict_image_name_output_file=./versions/image_digests_for_tags/$tag
mkdir -p "$(dirname "$strict_image_name_output_file")"
echo "$strict_image_name_output_file" # | tee "$image_name_with_digest"
