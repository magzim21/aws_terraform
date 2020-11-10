terraform {

  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}



### USER INPUT
variable "aws_accesskey" {
  type = string
}
variable "aws_secretkey" {
  type = string
}


provider "aws" {
  region     = "eu-north-1"
  access_key =  var.aws_accesskey
  secret_key =  var.aws_secretkey
}


data "aws_vpc" "default" {
  default = true  
}

data "aws_availability_zones" "az" {
    state = "available"
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}


resource "aws_autoscaling_attachment" "asg_elb_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  elb                    = aws_elb.my_elb.id
}

resource "aws_autoscaling_group" "asg" {
  availability_zones = data.aws_availability_zones.az.names
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 100
  launch_template {
    id      = aws_launch_template.my_ec2_templ.id
    version = "$Latest"
    }
  }



resource "aws_launch_template" "my_ec2_templ" {
  name_prefix = "redhat_asg_"
  image_id      = "ami-0b149b24810ebb323"
  instance_type = "t3.micro"
  # installing httpd server
  user_data = "IyEvYmluL2Jhc2gKc3VkbyB5dW0gLXkgdXBkYXRlICYmIHl1bSAteSBpbnN0YWxsIGh0dHBkCm15aXA9JChjdXJsIGNoZWNraXAuYW1hem9uYXdzLmNvbSkKZWNobyAiPGgyPkhFTExPIFdPUkxEIGZyb20gVGVycmFmb3JtIGFuZCBBV1M8L2gyPjxoNT4ke215aXB9PC9oNT4iIHwgc3VkbyB0ZWUgIC92YXIvd3d3L2h0bWwvaW5kZXguaHRtbApzdWRvIHNlcnZpY2UgaHR0cGQgc3RhcnQKc3VkbyBzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkLnNlcnZpY2U="
  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.simple_web_sg.id, data.aws_security_group.default.id]

}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("awazon_key_pair.pub")
}


resource "aws_security_group" "simple_web_sg" {
  name        = "simple_web_sg"
  description = "Verbous description"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "80 to 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "22 to 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # put trusted static ip addresses here
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "custom_name"
  }
}

resource "aws_elb" "my_elb" {
  name               = "my-elb-terraform-elb"
  availability_zones = data.aws_availability_zones.az.names
  # not necessary piece
  depends_on = [ aws_autoscaling_group.asg ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "my_elb-terraform"
  }
}
output "load_balancer_dns" {
  value = aws_elb.my_elb.dns_name 
}

