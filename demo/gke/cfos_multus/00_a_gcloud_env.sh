#/bin/bash -xe
filename="00_a_gcloud_env.sh.gen.sh"

cat << EOF > $filename
project=\$(gcloud config list --format="value(core.project)")
export region="asia-east1"
export zone="asia-east1-a"
gcloud config set project \$project
gcloud config set compute/region \$region
gcloud config set compute/zone \$zone
gcloud config list
EOF
chmod +x $filename

./$filename
