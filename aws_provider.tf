provider "aws" {
    region = var.aws_region
    profile = var.iam_profile

    default_tags {
        tags = {
            Provisioner = "Terraform"
            Owner = var.owner
            Project = "Sandbox VPC"
        }
    }
}

terraform {

   backend "s3" {
       bucket = "terraform-tfstate-freshboom"
       key    = "terraform.tfstate"
       region = "us-east-1"
   }



}

//required_version = ">=0.14.9" 

