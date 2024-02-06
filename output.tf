output "cloudfront_cache_policies_id" {
  value = {
    for key, value in var.cloudfront_cache_policies : key => aws_cloudfront_cache_policy.this[key].id
    if var.cloudfront_cache_policies != null
  }
}

output "cloudfront_distributions_id" {
  value = {
    for key, value in var.cloudfront_distributions : key => aws_cloudfront_distribution.this[key].id
  }
}
output "cloudfront_distributions_arn" {
  value = {
    for key, value in var.cloudfront_distributions : key => aws_cloudfront_distribution.this[key].arn
  }
}