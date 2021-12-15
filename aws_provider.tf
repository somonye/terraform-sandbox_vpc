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