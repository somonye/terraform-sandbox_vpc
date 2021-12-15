/* Variables used to determine AWS account, region, and credentials which
    should be used */

variable "aws_region" {
  type        = string
  description = "AWS region in which want to execute the Terraform code"
}

variable "iam_profile" {
  type = string
  description = "AWS Profile want to use to execute Terraform code."
}

# Default Tag Variables
variable "owner" {
    type = string
    description = "Name of person running Terraform code"
}