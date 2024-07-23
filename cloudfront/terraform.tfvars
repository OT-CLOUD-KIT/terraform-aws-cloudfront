cloudfront_cache_policies = {
  "CachingOptimized" = {
    comment                       = "Optimized caching policy"
    default_ttl                   = 86400
    max_ttl                       = 31536000
    min_ttl                       = 1
    cookies_config_behavior       = "none"
    headers_config_behavior       = "none"
    query_strings_config_behavior = "none"
  }
}

cloudfront_origin_request_policies = {
  "CORS-CustomOrigin" = {
    comment                       = "CORS policy for custom origin"
    cookies_config_behavior       = "none"
    headers_config_behavior       = "whitelist"
    headers_config_items          = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
    query_strings_config_behavior = "none"
  }
}

cloudfront_response_headers_policies = {
  "SimpleCORS" = {
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
  "my-distribution" = {
    #    aliases             = ["aliases if any"]
    viewer_certificate = {
      # acm_certificate_arn            = "acm certificate arn"
      cloudfront_default_certificate = true
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
    origin = {
      "CustomOrigin" = {
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
        target_origin_id         = "CustomOrigin"
        cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
        origin_request_policy_id = "59781a5b-3903-41f3-afcb-af62929ccde1"
      }
    }
    ordered_cache_behavior = {}
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
    }
  }
}
