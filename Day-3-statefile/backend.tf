terraform {
  backend "s3" {
    bucket = "tastychickenbucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
