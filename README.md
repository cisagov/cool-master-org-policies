# cool-master-org-policies #

[![GitHub Build Status](https://github.com/cisagov/cool-master-org-policies/workflows/build/badge.svg)](https://github.com/cisagov/cool-master-org-policies/actions)
[![License](https://img.shields.io/github/license/cisagov/cool-master-org-policies)](https://spdx.org/licenses/)
[![CodeQL](https://github.com/cisagov/cool-master-org-policies/workflows/CodeQL/badge.svg)](https://github.com/cisagov/cool-master-org-policies/actions/workflows/codeql-analysis.yml)

This is a Terraform module for creating AWS Organizations policies in a COOL
Master account that apply across the entire COOL AWS organization.

The following policies are currently managed by this module:

- A service control policy (SCP) that blocks all usage of Anthropic models in
  Amazon Bedrock, attached to the root of the organization.

## Pre-requisites ##

- [Terraform](https://www.terraform.io/) installed on your system.
- An accessible AWS S3 bucket to store Terraform state
  (specified in [backend.tf](backend.tf)).
- An accessible AWS DynamoDB database to store the Terraform state lock
  (specified in [backend.tf](backend.tf)).
- Access to all of the Terraform remote states specified in
  [remote_states.tf](remote_states.tf).
- The Master account's `ProvisionAccount` role must have the permissions to
  manage service control policies (SCPs) that are defined in
  [cisagov/cool-accounts](https://github.com/cisagov/cool-accounts).  Those
  permissions only apply to SCPs whose `Application` tag matches the value
  expected by that repository (`COOL - Master Org Policies` by default), so the
  `Application` tag in your `tags` variable must use that value.

## Usage ##

For the purposes of these instructions, assume the environment is named "dev";
replace "dev" in the instructions below with your environment name if needed.

1. Create a backend configuration file named `dev.tfconfig` containing the name
   of the bucket where Terraform state is stored for that environment.

    ```hcl
    bucket = "my-dev-terraform-state-bucket"
    ```

1. Initialize the Terraform backend for the "dev" environment using your backend
   configuration file:

    ```console
    terraform init -upgrade -backend-config=dev.tfconfig
    ```

    > [!NOTE] When performing this step for additional environments (i.e. not
    > your first environment), use the `-reconfigure` flag:
    >
    > ```console
    > terraform init -upgrade -backend-config=other-env.tfconfig -reconfigure
    > ```

1. Create a Terraform workspace (if you haven't already done so) by running
   `terraform workspace new dev`
1. Create a `dev.tfvars` file with all required variables and any optional
   variables that you wish to override (see [Inputs](#inputs) below for
   details):

   ```console
   tags = {
     Team        = "Your Team Name"
     Application = "COOL - Master Org Policies"
     Workspace   = "dev"
   }

   terraform_state_bucket = "my-terraform-state-bucket"
   ```

1. Run the command `terraform apply -var-file=dev.tfvars`.

<!-- BEGIN_TF_DOCS -->
## Requirements ##

| Name | Version |
| ---- | ------- |
| terraform | >= 1.1 |
| aws | >= 4.9 |

## Providers ##

| Name | Version |
| ---- | ------- |
| aws | >= 4.9 |
| aws.master | >= 4.9 |
| terraform | n/a |

## Modules ##

No modules.

## Resources ##

| Name | Type |
| ---- | ---- |
| [aws_organizations_policy.block_anthropic_models](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.block_anthropic_models_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.block_anthropic_models_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.cool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [terraform_remote_state.master](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| aws\_region | The AWS region to deploy into (e.g. us-east-1). | `string` | `"us-east-1"` | no |
| tags | Tags to apply to all AWS resources created.  The Application tag must be "COOL - Master Org Policies" (see the Pre-requisites section of the README). | `map(string)` | n/a | yes |
| terraform\_state\_bucket | The name of the S3 bucket where Terraform state is stored. | `string` | n/a | yes |

## Outputs ##

| Name | Description |
| ---- | ----------- |
| block\_anthropic\_models\_scp | The service control policy (SCP) that blocks all usage of Anthropic models in Amazon Bedrock. |
<!-- END_TF_DOCS -->

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, this is just the main directory.

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
