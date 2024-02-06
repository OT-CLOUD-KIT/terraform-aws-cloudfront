resource "aws_cloudfront_distribution" "this" {
  for_each            = var.cloudfront_distributions
  aliases             = each.value.aliases
  comment             = each.value.comment != null ? each.value.comment : each.key
  default_root_object = each.value.default_root_object
  enabled             = each.value.enabled
  http_version        = each.value.http_version
  is_ipv6_enabled     = each.value.is_ipv6_enabled
  price_class         = each.value.price_class
  retain_on_delete    = each.value.retain_on_delete
  wait_for_deployment = each.value.wait_for_deployment
  web_acl_id          = each.value.web_acl_id

  dynamic "logging_config" {
    for_each = each.value.logging_config

    content {
      include_cookies = logging_config.value.include_cookies
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
    }

  }
  dynamic "origin" {
    for_each = each.value.origin

    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id != null ? origin.value.origin_id : origin.key
      origin_path              = origin.value.origin_path
      connection_attempts      = origin.value.connection_attempts
      connection_timeout       = origin.value.connection_timeout
      origin_access_control_id = origin.value.origin_access_control_name != null ? aws_cloudfront_origin_access_control.this[origin.value.origin_access_control_name].id : origin.value.origin_access_control_id

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config

        content {
          origin_access_identity = s3_origin_config.value.cloudfront_access_identity_path
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_header
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = each.value.origin_group != null ? each.value.origin_group : {}

    content {
      origin_id = origin_group.value.origin_id
      failover_criteria {
        status_codes = origin_group.value.failover_status_codes
      }

      member {
        origin_id = origin_group.value.primary_member_origin_id
      }

      member {
        origin_id = origin_group.value.secondary_member_origin_id
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = each.value.default_cache_behavior

    content {
      target_origin_id       = default_cache_behavior.value.target_origin_id
      viewer_protocol_policy = default_cache_behavior.value.viewer_protocol_policy

      allowed_methods           = default_cache_behavior.value.allowed_methods
      cached_methods            = default_cache_behavior.value.cached_methods
      compress                  = default_cache_behavior.value.compress
      field_level_encryption_id = default_cache_behavior.value.field_level_encryption_id
      smooth_streaming          = default_cache_behavior.value.smooth_streaming
      trusted_signers           = default_cache_behavior.value.trusted_signers
      trusted_key_groups        = default_cache_behavior.value.trusted_key_groups

      cache_policy_id            = default_cache_behavior.value.cache_policy_name != null ? aws_cloudfront_cache_policy.this[default_cache_behavior.value.cache_policy_name].id : default_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = default_cache_behavior.value.origin_request_policy_name != null ? aws_cloudfront_origin_request_policy.this[default_cache_behavior.value.origin_request_policy_name].id : default_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = default_cache_behavior.value.response_headers_policy_name != null ? aws_cloudfront_response_headers_policy.this[default_cache_behavior.value.response_headers_policy_name].id : default_cache_behavior.value.response_headers_policy_id
      realtime_log_config_arn    = default_cache_behavior.value.realtime_log_config_arn

      min_ttl     = default_cache_behavior.value.min_ttl
      default_ttl = default_cache_behavior.value.default_ttl
      max_ttl     = default_cache_behavior.value.max_ttl

      dynamic "forwarded_values" {
        for_each = default_cache_behavior.value.cache_policy_id != null || default_cache_behavior.value.cache_policy_name != null ? {} : default_cache_behavior.value.forwarded_values


        content {
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = forwarded_values.value.query_string_cache_keys
          headers                 = forwarded_values.value.headers

          cookies {
            forward           = forwarded_values.value.cookies_forward
            whitelisted_names = forwarded_values.value.cookies_whitelisted_names
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda_function_association

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      dynamic "function_association" {
        for_each = default_cache_behavior.value.function_association

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = each.value.ordered_cache_behavior
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern != null ? ordered_cache_behavior.value.path_pattern : ordered_cache_behavior.key
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      allowed_methods           = ordered_cache_behavior.value.allowed_methods
      cached_methods            = ordered_cache_behavior.value.cached_methods
      compress                  = ordered_cache_behavior.value.compress
      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id
      smooth_streaming          = ordered_cache_behavior.value.smooth_streaming
      trusted_signers           = ordered_cache_behavior.value.trusted_signers
      trusted_key_groups        = ordered_cache_behavior.value.trusted_key_groups

      cache_policy_id            = ordered_cache_behavior.value.cache_policy_name != null ? aws_cloudfront_cache_policy.this[ordered_cache_behavior.value.cache_policy_name].id : ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_name != null ? aws_cloudfront_origin_request_policy.this[ordered_cache_behavior.value.origin_request_policy_name].id : ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_name != null ? aws_cloudfront_response_headers_policy.this[ordered_cache_behavior.value.response_headers_policy_name].id : ordered_cache_behavior.value.response_headers_policy_id
      realtime_log_config_arn    = ordered_cache_behavior.value.realtime_log_config_arn

      min_ttl     = ordered_cache_behavior.value.min_ttl
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.cache_policy_id != null || ordered_cache_behavior.value.cache_policy_name != null ? {} : ordered_cache_behavior.value.forwarded_values

        content {
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = forwarded_values.value.query_string_cache_keys
          headers                 = forwarded_values.value.headers

          cookies {
            forward           = forwarded_values.value.cookies_forward
            whitelisted_names = forwarded_values.value.cookies_whitelisted_names
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = each.value.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = each.value.viewer_certificate.cloudfront_default_certificate
    iam_certificate_id             = each.value.viewer_certificate.iam_certificate_id
    minimum_protocol_version       = each.value.viewer_certificate.minimum_protocol_version
    ssl_support_method             = each.value.viewer_certificate.ssl_support_method
  }

  dynamic "custom_error_response" {
    for_each = each.value.custom_error_response

    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  restrictions {
    dynamic "geo_restriction" {
      for_each = each.value.geo_restriction

      content {
        restriction_type = geo_restriction.value.restriction_type
        locations        = geo_restriction.value.locations
      }
    }
  }
  tags = merge({
    Name = each.key,
    },
    each.value.tags
  )
}

resource "aws_cloudfront_cache_policy" "this" {
  for_each    = var.cloudfront_cache_policies
  name        = each.key
  comment     = each.value.comment
  default_ttl = each.value.default_ttl
  max_ttl     = each.value.max_ttl
  min_ttl     = each.value.min_ttl
  parameters_in_cache_key_and_forwarded_to_origin {

    cookies_config {
      cookie_behavior = each.value.cookies_config_behavior
      dynamic "cookies" {
        for_each = length(each.value.cookies_config_items) > 0 ? ["1"] : []
        content {
          items = each.value.cookies_config_items
        }
      }
    }
    headers_config {
      header_behavior = each.value.headers_config_behavior
      dynamic "headers" {
        for_each = length(each.value.headers_config_items) > 0 ? ["1"] : []
        content {
          items = each.value.headers_config_items
        }
      }
    }
    query_strings_config {
      query_string_behavior = each.value.query_strings_config_behavior
      dynamic "query_strings" {
        for_each = length(each.value.query_strings_config_items) > 0 ? ["1"] : []
        content {
          items = each.value.query_strings_config_items
        }
      }
    }
    enable_accept_encoding_brotli = each.value.enable_accept_encoding_brotli
    enable_accept_encoding_gzip   = each.value.enable_accept_encoding_gzip
  }
}

resource "aws_cloudfront_origin_request_policy" "this" {
  for_each = var.cloudfront_origin_request_policies
  name     = each.key
  comment  = each.value.comment

  cookies_config {
    cookie_behavior = each.value.cookies_config_behavior
    dynamic "cookies" {
      for_each = length(each.value.cookies_config_items) > 0 ? ["1"] : []
      content {
        items = each.value.cookies_config_items
      }
    }
  }
  headers_config {
    header_behavior = each.value.headers_config_behavior
    dynamic "headers" {
      for_each = length(each.value.headers_config_items) > 0 ? ["1"] : []
      content {
        items = each.value.headers_config_items
      }
    }
  }
  query_strings_config {
    query_string_behavior = each.value.query_strings_config_behavior
    dynamic "query_strings" {
      for_each = length(each.value.query_strings_config_items) > 0 ? ["1"] : []
      content {
        items = each.value.query_strings_config_items
      }
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "this" {
  for_each = var.cloudfront_response_headers_policies
  name     = each.key
  comment  = each.value.comment

  dynamic "cors_config" {
    for_each = each.value.cors_config
    content {
      access_control_allow_credentials = cors_config.value.access_control_allow_credentials

      access_control_allow_headers {
        items = cors_config.value.access_control_allow_headers
      }

      access_control_allow_methods {
        items = cors_config.value.access_control_allow_methods
      }

      access_control_allow_origins {
        items = cors_config.value.access_control_allow_origins
      }

      access_control_max_age_sec = cors_config.value.access_control_max_age_sec

      origin_override = cors_config.value.origin_override
    }
  }

  dynamic "custom_headers_config" {
    for_each = each.value.custom_headers_config
    content {

      items {
        header   = custom_headers_config.value.header
        override = custom_headers_config.value.override
        value    = custom_headers_config.value.value
      }
    }
  }
  dynamic "security_headers_config" {
    for_each = each.value.security_headers_config

    content {

      dynamic "content_security_policy" {
        for_each = security_headers_config.value.content_security_policy

        content {
          content_security_policy = content_security_policy.value.content_security_policy
          override                = content_security_policy.value.override
        }
      }

      dynamic "content_type_options" {
        for_each = security_headers_config.value.content_type_options

        content {
          override = content_type_options.value.override
        }
      }

      dynamic "frame_options" {
        for_each = security_headers_config.value.frame_options

        content {
          frame_option = frame_options.value.frame_option
          override     = frame_options.value.override
        }

      }

      dynamic "referrer_policy" {
        for_each = security_headers_config.value.referrer_policy

        content {
          referrer_policy = referrer_policy.value.referrer_policy
          override        = referrer_policy.value.override
        }

      }
      dynamic "strict_transport_security" {
        for_each = security_headers_config.value.strict_transport_security

        content {
          access_control_max_age_sec = strict_transport_security.value.access_control_max_age_sec
          include_subdomains         = strict_transport_security.value.include_subdomains
          override                   = strict_transport_security.value.override
          preload                    = strict_transport_security.value.preload
        }
      }

      dynamic "xss_protection" {
        for_each = security_headers_config.value.xss_protection

        content {
          mode_block = xss_protection.value.mode_block
          override   = xss_protection.value.override
          protection = xss_protection.value.protection
          report_uri = xss_protection.value.report_uri
        }
      }
    }

  }
  dynamic "server_timing_headers_config" {
    for_each = each.value.server_timing_headers_config

    content {
      enabled       = server_timing_headers_config.value.enabled
      sampling_rate = server_timing_headers_config.value.sampling_rate
    }

  }

}

resource "aws_cloudfront_origin_access_control" "this" {
  for_each                          = var.cloudfront_origin_access_controls
  name                              = each.value.name != null ? each.value.name : each.key
  description                       = each.value.description
  origin_access_control_origin_type = each.value.origin_access_control_origin_type
  signing_behavior                  = each.value.signing_behavior
  signing_protocol                  = each.value.signing_protocol
}

