output "cloudfront_cache_policies_id" {
  value = {
    for key, value in aws_cloudfront_cache_policy.this : key => value.id
  }
}

output "cloudfront_distributions_id" {
  value = {
    for key, value in aws_cloudfront_distribution.this : key => value.id
  }
}

output "cloudfront_distributions_arn" {
  value = {
    for key, value in aws_cloudfront_distribution.this : key => value.arn
  }
}

output "cloudfront_request_policies_id" {
  value = {
    for key, value in aws_cloudfront_origin_request_policy.this : key => value.id
  }
}

output "cloudfront_headers_policies_id" {
  value = {
    for key, value in aws_cloudfront_response_headers_policy.this : key => value.id
  }
}
