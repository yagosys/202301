function install_aws_v2_cli {
if ! command -v aws > /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi
}

function config_aws {
if ! aws configure list &> /dev/null; then
  echo "AWS CLI is not configured properly. Please run 'aws configure' to set up your AWS credentials."
  exit 1
else
  echo "AWS CLI is configured properly."
  exit 0
fi
}

function install_terraform {
TERRAFORM_VERSION=1.3.7
if ! command -v terraform > /dev/null; then
        if ! command -v unzip > /dev/null; then
  	sudo apt-get update
  	sudo apt-get install unzip
	fi

  TERRAFORM_VERSION=$(curl --silent https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | sort -V | egrep -v 'beta|rc' | tail -1)
  curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
  unzip terraform.zip
  sudo mv terraform /usr/local/bin/
  rm terraform.zip
fi
}

function generate_rsa_keypair {
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  #ssh-keygen -f "$HOME/.ssh/id_rsa" -t rsa -b 4096 -N "" -q
  ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519cfoslab
fi
}

echo check install
echo -----
echo check aws cli
install_aws_v2_cli
echo check aws configure
config_aws
echo check terraform installtion
install_terraform
echo check default ssh keypair
generate_rsa_keypair
echo done
