resource "aws_instance" "name" {
    ami = "ami-0c1fe732b5494dc14"
    instance_type = "t2.micro"
    tags = {
      Name = "test"
    }
  
}
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "devnew"
    }
  
}