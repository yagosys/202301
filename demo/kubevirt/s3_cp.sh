imagename="faz74.qcow2"
bucket=$(aws s3 ls | grep wandy  | cut -d ' ' -f 3)
aws s3 cp $imagename s3://$bucket
aws s3api put-object-acl --bucket $bucket --key $imagename --acl public-read
#wget  https://$bucket.s3.ap-southeast-1.amazonaws.com/$imagename
