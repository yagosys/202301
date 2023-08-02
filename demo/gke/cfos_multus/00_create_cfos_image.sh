gzip -d FOS_X64_DOCKER-v7-build0231-FORTINET.tar.gz
docker load < FOS_X64_DOCKER-v7-build0231-FORTINET.tar
docker images | grep ^fos
PROJECT_ID=$(gcloud config list --format="value(core.project)")
docker tag fos:latest gcr.io/$PROJECT_ID/fos:7231
gcloud auth configure-docker
docker push gcr.io/$PROJECT_ID/fos:7231
export cfos_image="gcr.io/$PROJECT_ID/fos:7231"
echo $cfos_image

