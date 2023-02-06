#https://cloud-images.ubuntu.com/daily/server/locator/ 
#region="ap-southeast-1"
ubuntu="099720109477"
architecture="x86_64"
releasename='*ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64*'
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
echo locals{
echo ec2_image_id_map={
for region in $regions; do
	name=$(aws --region $region ec2 describe-images --owners $ubuntu --filters Name=architecture,Values=$architecture Name=name,Values=$releasename  Name=root-device-type,Values=ebs | awk -F ': ' '/"Name"/ { print $2 | "sort" }' | tr -d '",' | tail -1)
	
	ami_id=$(\
	    aws --region $region ec2 describe-images --owners $ubuntu --filters Name=name,Values="$name"  --filters Name=name,Values="$name" | awk -F ': ' '/"ImageId"/ { print $2 }' | tr -d '",')
	echo $region = \"$ami_id\" 
done
echo }
echo }

