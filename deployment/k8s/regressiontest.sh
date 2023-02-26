REGIONS=("ap-east-1" "ap-southeast-1" "us-east-1" )

for region in "${REGIONS[@]}"
do
   echo "Deploying to region: $region"
            suffix="terraform_apply_output"
            filename=$region$suffix
            touch "$filename"
            terraform apply -var region=$region --auto-approve | tee -a  $filename
            ./copy_ssh_key_to_master.sh 2>  $region.result
            sleep 30
            #./pingcheck.sh 2>> $region.result
            ./pingcheck.sh  >> $region.result 2>&1
            ./curlcheck.sh >> $region.result 2>&1
            terraform destroy --var region=$region --auto-approve | tee -a $filename
   done
