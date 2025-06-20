module "network" {
  source                               = "../"
  cloudfront_distributions             = var.cloudfront_distributions
  cloudfront_cache_policies            = var.cloudfront_cache_policies
  cloudfront_origin_request_policies   = var.cloudfront_origin_request_policies
  cloudfront_response_headers_policies = var.cloudfront_response_headers_policies
  cloudfront_origin_access_controls    = var.cloudfront_origin_access_controls
}
