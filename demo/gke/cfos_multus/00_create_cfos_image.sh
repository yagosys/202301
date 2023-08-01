gzip -d FOS_X64_DOCKER-v7-build0231-FORTINET.tar.gz
docker load < FOS_X64_DOCKER-v7-build0231-FORTINET.tar
docker images | grep ^fos
PROJECT_ID=$(gcloud config list --format="value(core.project)")
docker tag fos:latest gcr.io/$PROJECT_ID/fos:7231
gcloud auth configure-docker
docker push gcr.io/$PROJECT_ID/fos:7231
export cfos_image="gcr.io/$PROJECT_ID/fos:7231"
echo $cfos_image

[[ -z $cfos_license_input_file ]] && cfos_license_input_file="FGVMULTM23000044.lic"
[[ -f $cfos_license_input_file ]] ||  echo $cfos_license_input_file does not exist
licensestring=$(sed '1d;$d' $cfos_license_input_file | tr -d '\n')
cat <<EOF >fos_license.yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: fos-license
    labels:
        app: fos
        category: license
data:
    license: |
     -----BEGIN FGT VM LICENSE-----
     $licensestring
     -----END FGT VM LICENSE-----
     
EOF
ls -l fos_license.yaml
