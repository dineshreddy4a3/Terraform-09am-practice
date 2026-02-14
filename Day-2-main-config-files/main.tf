resource "aws_instance" "dev" {
  ami           = var.ami-id
  instance_type = var.instance-type
  tags = {
    Name = "ec2test"
  }

}
