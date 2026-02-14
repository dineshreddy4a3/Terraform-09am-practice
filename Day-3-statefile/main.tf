provider "aws" {
  
}

resource "aws_instance" "dev" {
    ami = "ami-0c1fe732b5494dc14"
    instance_type = "t2.micro"
    tags = {
      Name = "devtest"
    }

  
}
