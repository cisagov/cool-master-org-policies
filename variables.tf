# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all AWS resources created.  The Application tag must be \"COOL - Master Org Policies\" (see the Pre-requisites section of the README)."
  nullable    = false
  type        = map(string)
  validation {
    condition     = lookup(var.tags, "Application", "") == "COOL - Master Org Policies"
    error_message = "The Application tag must be \"COOL - Master Org Policies\", since the Master account's ProvisionAccount role can only manage SCPs with that tag (see manage_scps_application_tag in cisagov/cool-accounts)."
  }
}

variable "terraform_state_bucket" {
  description = "The name of the S3 bucket where Terraform state is stored."
  nullable    = false
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------
variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to deploy into (e.g. us-east-1)."
  nullable    = false
  type        = string
}
