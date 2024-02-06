variable "cloudfront_distributions" {
  type = map(object({
    aliases             = optional(list(string))
    comment             = optional(string)
    default_root_object = optional(string)
    enabled             = optional(bool, true)
    http_version        = optional(string, "http2")
    is_ipv6_enabled     = optional(bool, true)
    price_class         = optional(string)
    retain_on_delete    = optional(bool, false)
    wait_for_deployment = optional(bool, true)
    web_acl_id          = optional(string)

    logging_config = optional(list(object({
      include_cookies = optional(bool, false)
      bucket          = string
      prefix          = optional(string)
    })), [])

    origin = map(object({
      domain_name                = string
      origin_id                  = optional(string)
      origin_path                = optional(string)
      connection_attempts        = optional(number, 3)
      connection_timeout         = optional(number, 10)
      origin_access_control_id   = optional(string, null)
      origin_access_control_name = optional(string, null)

      custom_header = optional(list(object({
        name  = string
        value = string
      })), [])
      origin_shield = optional(list(object({
        enabled              = bool
        origin_shield_region = string
      })), [])
      s3_origin_config = optional(list(object({
        origin_access_identity = string
      })), [])

      custom_origin_config = optional(map(object({
        http_port                = optional(number, 80)
        https_port               = optional(number, 443)
        origin_protocol_policy   = optional(string, "match-viewer")
        origin_ssl_protocols     = optional(list(string), ["TLSv1"])
        origin_keepalive_timeout = optional(number)
        origin_read_timeout      = optional(number)

      })), {})
    }))
    origin_group = optional(map(object({
      origin_id                  = string
      failover_status_codes      = number
      primary_member_origin_id   = string
      secondary_member_origin_id = string
    })), {})

    default_cache_behavior = map(object({
      target_origin_id             = string
      allowed_methods              = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      cached_methods               = optional(list(string), ["GET", "HEAD"])
      compress                     = optional(bool, false)
      field_level_encryption_id    = optional(string)
      smooth_streaming             = optional(bool, false)
      trusted_signers              = optional(list(string))
      trusted_key_groups           = optional(list(string))
      cache_policy_id              = optional(string)
      cache_policy_name            = optional(string)
      origin_request_policy_id     = optional(string)
      origin_request_policy_name   = optional(string)
      response_headers_policy_id   = optional(string)
      response_headers_policy_name = optional(string)
      realtime_log_config_arn      = optional(string)
      min_ttl                      = optional(number)
      default_ttl                  = optional(number)
      max_ttl                      = optional(number)
      viewer_protocol_policy       = optional(string, "redirect-to-https")

      forwarded_values = optional(map(object({
        query_string              = optional(bool, false)
        query_string_cache_keys   = optional(list(string))
        headers                   = optional(list(string))
        cookies_forward           = optional(string, "none")
        cookies_whitelisted_names = optional(list(string))

      })), { "default" = { query_string = false, cookies_forward = "none" } })
      lambda_function_association = optional(list(object({
        event_type   = string
        lambda_arn   = string
        include_body = optional(bool)
      })), [])

      function_association = optional(list(object({
        event_type   = string
        function_arn = string
      })), [])

    }))

    ordered_cache_behavior = optional(map(object({
      target_origin_id             = string
      path_pattern                 = optional(string)
      allowed_methods              = optional(list(string), ["GET", "HEAD", "OPTIONS"])
      cached_methods               = optional(list(string), ["GET", "HEAD", "OPTIONS"])
      compress                     = optional(bool, false)
      field_level_encryption_id    = optional(string)
      smooth_streaming             = optional(bool)
      trusted_signers              = optional(list(string))
      trusted_key_groups           = optional(list(string))
      cache_policy_id              = optional(string)
      cache_policy_name            = optional(string)
      origin_request_policy_id     = optional(string)
      origin_request_policy_name   = optional(string)
      response_headers_policy_id   = optional(string)
      response_headers_policy_name = optional(string)
      realtime_log_config_arn      = optional(string)
      min_ttl                      = optional(number)
      default_ttl                  = optional(number)
      max_ttl                      = optional(number)
      viewer_protocol_policy       = optional(string, "redirect-to-https")

      forwarded_values = optional(map(object({
        query_string              = optional(bool, false)
        query_string_cache_keys   = optional(list(string))
        headers                   = optional(list(string))
        cookies_forward           = optional(string, "none")
        cookies_whitelisted_names = optional(list(string))

      })), { "default" = { query_string = false, cookies_forward = "none" } })

      lambda_function_association = optional(list(object({
        event_type   = string
        lambda_arn   = string
        include_body = optional(bool)
      })), [])

      function_association = optional(list(object({
        event_type   = string
        function_arn = string
      })), [])

    })), {})

    viewer_certificate = optional(object({
      acm_certificate_arn            = optional(string)
      cloudfront_default_certificate = optional(bool, true)
      iam_certificate_id             = optional(string)
      minimum_protocol_version       = optional(string, "TLSv1.2_2021")
      ssl_support_method             = optional(string)
    }), {})

    custom_error_response = optional(map(object({
      error_code            = number
      response_code         = optional(number)
      response_page_path    = optional(string)
      error_caching_min_ttl = optional(number)
    })), {})

    geo_restriction = optional(map(object({
      restriction_type = string
      locations        = list(string)
    })), { "allow all" = { restriction_type = "none", locations = [] } })

    tags = optional(map(string))
  }))
}

variable "cloudfront_cache_policies" {
  type = map(object({
    comment                       = optional(string)
    default_ttl                   = optional(number, 50)
    max_ttl                       = optional(number, 100)
    min_ttl                       = optional(number, 1)
    cookies_config_behavior       = string
    cookies_config_items          = optional(list(string), [])
    headers_config_behavior       = string
    headers_config_items          = optional(list(string), [])
    query_strings_config_behavior = string
    query_strings_config_items    = optional(list(string), [])
    enable_accept_encoding_brotli = optional(bool, false)
    enable_accept_encoding_gzip   = optional(bool, false)
  }))
}

variable "cloudfront_origin_request_policies" {
  type = map(object({
    comment                       = optional(string)
    cookies_config_behavior       = string
    cookies_config_items          = optional(list(string), [])
    headers_config_behavior       = string
    headers_config_items          = optional(list(string), [])
    query_strings_config_behavior = string
    query_strings_config_items    = optional(list(string), [])
  }))
}


variable "cloudfront_response_headers_policies" {
  type = map(object({
    comment = optional(string)
    cors_config = optional(list(object({
      access_control_allow_credentials = bool
      access_control_allow_headers     = list(string)
      access_control_allow_methods     = list(string)
      access_control_allow_origins     = list(string)
      access_control_max_age_sec       = optional(number)
      origin_override                  = bool
    })), [])

    custom_headers_config = optional(list(object({
      header   = string
      override = bool
      value    = string
    })), [])

    security_headers_config = optional(list(object({
      content_security_policy = optional(list(object({
        content_security_policy = string
        override                = bool
      })), [])

      content_type_options = optional(list(object({
        override = bool
      })), [])

      frame_options = optional(list(object({
        frame_option = string
        override     = bool
      })), [])

      referrer_policy = optional(list(object({
        referrer_policy = string
        override        = bool
      })), [])

      strict_transport_security = optional(list(object({
        access_control_max_age_sec = number
        include_subdomains         = optional(bool)
        override                   = bool
        preload                    = optional(bool)
      })), [])

      xss_protection = optional(list(object({
        mode_block = bool
        override   = bool
        protection = bool
        report_uri = optional(string)
      })), [])
    })), [])

    server_timing_headers_config = optional(list(object({
      enabled       = bool
      sampling_rate = number
    })), [])
  }))

}

variable "cloudfront_origin_access_controls" {
  type = map(object({
    name                              = optional(string)
    description                       = optional(string)
    origin_access_control_origin_type = optional(string, "s3")
    signing_behavior                  = optional(string, "always")
    signing_protocol                  = optional(string, "sigv4")
  }))
  default = {}
}
