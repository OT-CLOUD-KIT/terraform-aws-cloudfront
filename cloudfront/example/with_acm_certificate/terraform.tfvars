cloudfront_cache_policies = {
  "cache_policy" = {
    comment                       = "Optimized caching policy"
    cookies_config_behavior       = "none"
    headers_config_behavior       = "none"
    query_strings_config_behavior = "none"
  }
}

cloudfront_origin_request_policies = {
  "origin_request_policy" = {
    comment                       = "CORS policy for custom origin"
    cookies_config_behavior       = "none"
    headers_config_behavior       = "none"
    query_strings_config_behavior = "none"
  }
}

cloudfront_response_headers_policies = {
  "response_header_policy" = {
    comment = "Simple CORS headers policy"
    cors_config = [{
      access_control_allow_credentials = true
      access_control_allow_headers     = ["Content-Type", "Authorization"]
      access_control_allow_methods     = ["GET", "POST"]
      access_control_allow_origins     = ["*"]
      origin_override                  = true
    }]
  }
}

cloudfront_distributions = {
  "name of the distribution" = {
    viewer_certificate = {
      acm_certificate_arn            = "acm certificate arn"
      cloudfront_default_certificate = true
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
    origin = {
      "ot-cdn-testing-bucket" = {
        domain_name = "ot-cdn-testing-bucket.s3.us-east-2.amazonaws.com"
        custom_origin_config = {
          a = {
            http_port              = 80
            origin_protocol_policy = "http-only"
          }
        }
      }
    }
    default_cache_behavior = {
      "default_cache_behavior" = {
        target_origin_id         = "ot-cdn-testing-bucket"
      }
    }
    ordered_cache_behavior = {}
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
    }
  }
}
