terraform {
  backend "s3" {
    bucket  = "ot-cloud-kit-bucket"
    key     = "ot/module/cloud_front/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

