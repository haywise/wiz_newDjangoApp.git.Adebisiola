# configured aws provider with proper credentials
provider "aws" {
  region     = "us-east-1"
  profile    = "Bisi"
  
}


# Create a VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow webserver inbound traffic"
  vpc_id      = aws_default_vpc.default.id  # Added .id

  ingress {
    description = "Web Traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Any ip address/ any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "firstinstance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
   key_name               = "public-kp"
  availability_zone      = "us-east-1a"
  user_data              =  "${file("install.jenkins.sh")}"


  tags = {
    Name = "Jenkins_Server"
  }
}

# use data source to get a registered ubuntu ami
data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# print the url of the jenkins server
output "Jenkins_website_url" {
  value     = join ("", ["http://", aws_instance.firstinstance.public_ip, ":", "8080"])
  description = "Jenkins Server"
}


#output "website-url" {
 # value       = "${aws_instance.firstinstance.*.public_ip}"
  #description = "PublicIP address details"
#}
# aws_instance.ec2_instance.public_dns
