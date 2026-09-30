# ------------------------------------------------------------------------------
# Retrieve the effective Account ID, User ID, and ARN in which Terraform is
# authorized.  This is used to calculate the session names for assumed roles.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Retrieve information about the AWS organization managed by the Master
# account.  This is used to look up the ID of the organization's root.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "cool" {
  provider = aws.master
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  # An AWS organization has exactly one root.
  root_id = data.aws_organizations_organization.cool.roots[0].id
}
