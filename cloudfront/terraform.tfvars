cloudfront_cache_policies = {
  "cache_policy_name" = {
    comment                       = "Optimized caching policy"
    cookies_config_behavior       = "none"
    headers_config_behavior       = "none"
    query_strings_config_behavior = "none"
  }
}

cloudfront_origin_request_policies = {
  "origin_request_policy_name" = {
    comment                       = "CORS policy for custom origin"
    cookies_config_behavior       = "none"
    headers_config_behavior       = "none"
    query_strings_config_behavior = "none"
  }
}

cloudfront_response_headers_policies = {
  "response_header_policy_name" = {
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
  "name_of_the_cloudfront_distribution" = {
    aliases             = ["aliases if any"]
    viewer_certificate = {
      acm_certificate_arn            = "acm certificate arn"
      cloudfront_default_certificate = true
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
    origin = {
      "origin_name" = {
        domain_name = "domain name"
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
        target_origin_id         = "target policy id"
        cache_policy_id          = "cache policy id"
        origin_request_policy_id = "request policy id"
      }
    }
    ordered_cache_behavior = {}
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
    }
  }
}
