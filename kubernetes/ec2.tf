# Define the provider
provider "aws" {
  alias = "second"
  region = "us-east-1"  # Change to your desired region
  profile = "Abdulhakeem"
}

# Create an S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "atrihomes-mongodb-${random_id.example_bucket_suffix.hex}"
}

# Create a random ID for the bucket suffix
resource "random_id" "example_bucket_suffix" {
  byte_length = 4
}

# Create a security group for the Ubuntu instance
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow inbound traffic on port 22 and 80"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
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

# Launch an Ubuntu instance
resource "aws_instance" "example_instance" {
  ami           = "ami-0c7217cdde317cfec"  # Replace with your desired AMI ID
  instance_type = "t2.micro"               # Change to your desired instance type
  security_groups = [aws_security_group.example_sg.name]
  key_name        = "kim"

  tags = {
    Name = "mongodb_server"
  }
}


# Output the public IP address of the Ubuntu instance
output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}

# Output the name of the S3 bucket
output "bucket_name" {
  value = aws_s3_bucket.example_bucket.bucket
}


# Output the name of the S3 bucket
output "bucket_name" {
  value = aws_s3_bucket.example_bucket.bucket
}
