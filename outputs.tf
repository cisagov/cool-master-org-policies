output "block_anthropic_models_scp" {
  description = "The service control policy (SCP) that blocks all usage of Anthropic models in Amazon Bedrock."
  value       = aws_organizations_policy.block_anthropic_models
}
