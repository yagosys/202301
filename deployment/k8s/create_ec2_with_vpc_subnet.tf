resource "aws_vpc" "k8slab" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "k8slab-vpc"
  }
}

resource "aws_internet_gateway" "k8slab" {
  vpc_id = aws_vpc.k8slab.id

  tags = {
    Name = "k8slab-internet-gateway"
  }
}


resource "aws_subnet" "k8slab" {
  vpc_id            = aws_vpc.k8slab.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  //availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8slab-public-subnet"
  }
}

resource "aws_route_table" "k8slab" {
  vpc_id = aws_vpc.k8slab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8slab.id
  }

  tags = {
    Name = "k8slab-route-table"
  }
}

resource "aws_route_table_association" "k8slab" {
  subnet_id      = aws_subnet.k8slab.id
  route_table_id = aws_route_table.k8slab.id
}

resource "aws_security_group" "k8slab" {
  name   = "k8slab-security-group"
  vpc_id = aws_vpc.k8slab.id

  ingress {
    from_port   = var.tcpport
    to_port     = var.tcpport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8slab" {
  ami           = var.ami_image_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.k8slab.id
  security_groups = [aws_security_group.k8slab.id]
  key_name = var.key_name
  user_data     = templatefile(
	"${path.module}/user-data.tftpl",
	 {
	 }
  )
  provisioner "file" {
    source = var.cfosLicense
    destination ="/home/ubuntu/fos_license.yaml"
   }
 
  provisioner "file" {
    source = "/home/i/202301/deployment/k8s/check.sh"
    destination = "/home/ubuntu/check.sh"
  } 

  provisioner "file" {
#    source = "/home/i/202301/deployment/private/dockerinterbeing.yaml"
    source = var.dockerinterbeing
    destination = "/home/ubuntu/.dockerinterbeing.yaml"
  }
  tags = {
    Name = "k8slab"
  }

   provisioner "remote-exec" {
     inline = [
      "tail -f /var/log/user-data.log --retry | sed '/deploymentcompleted/q' ",
#      "chmod +x /home/ubuntu/check.sh",
#      "/home/ubuntu/check.sh",
    ]
   }
  connection {
    host = "${aws_instance.k8slab.public_ip}"
    type = "ssh"
    port = "22"
    user = "ubuntu"
    timeout = "180s"
    private_key = "${file("${var.key_location}")}"
  }
}

output "instance_public_ip" {
  value = aws_instance.k8slab.public_ip
}


