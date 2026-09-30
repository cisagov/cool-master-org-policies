# ------------------------------------------------------------------------------
# Create a service control policy (SCP) that blocks all usage of Anthropic
# models in Amazon Bedrock and attach it to the root of the organization.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "block_anthropic_models_doc" {
  statement {
    actions = [
      "bedrock-mantle:CountTokens",
      "bedrock-mantle:CreateFineTuningJob",
      "bedrock-mantle:CreateInference",
    ]
    condition {
      test     = "StringLike"
      values   = ["anthropic.*"]
      variable = "bedrock-mantle:Model"
    }
    effect    = "Deny"
    resources = ["*"]
    sid       = "DenyAnthropicMantleInference"
  }

  statement {
    actions = [
      "bedrock:CreateModelInvocationJob",
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    effect = "Deny"
    resources = [
      "arn:aws:bedrock:*::foundation-model/anthropic.*",
      "arn:aws:bedrock:*:*:inference-profile/*anthropic.*",
    ]
    sid = "DenyAnthropicRuntimeInference"
  }

  statement {
    actions = [
      "bedrock:CreateInferenceProfile",
      "bedrock:CreateModelCustomizationJob",
      "bedrock:CreatePromptRouter",
      "bedrock:CreateProvisionedModelThroughput",
    ]
    effect = "Deny"
    resources = [
      "arn:aws:bedrock:*::foundation-model/anthropic.*",
      "arn:aws:bedrock:*:*:inference-profile/*anthropic.*",
    ]
    sid = "DenyAnthropicModelWrappingAndProvisioning"
  }
}

# The SCP
resource "aws_organizations_policy" "block_anthropic_models" {
  provider = aws.master

  content     = data.aws_iam_policy_document.block_anthropic_models_doc.json
  description = "Block all usage of Anthropic models in bedrock and bedrock-mantle."
  name        = "cool-block-anthropic-models"
  type        = "SERVICE_CONTROL_POLICY"
}

# Attach the SCP to the root so that it applies to every account in the
# organization.
resource "aws_organizations_policy_attachment" "block_anthropic_models_root" {
  provider = aws.master

  policy_id = aws_organizations_policy.block_anthropic_models.id
  target_id = local.root_id
}
