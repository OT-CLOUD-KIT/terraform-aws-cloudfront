resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases             = var.alias
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enable
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id

  dynamic "origin" {
    for_each = [for i in var.s3_origin_config : {
      name          = i.domain_name
      id            = i.origin_id
      identity      = lookup(i, "origin_access_identity", null)
      path          = lookup(i, "origin_path", "")
      custom_header = lookup(i, "custom_header", null)
    }]

    content {
      domain_name = origin.value.name
      origin_id   = origin.value.id
      origin_path = origin.value.path
      dynamic "custom_header" {
        for_each = origin.value.custom_header == null ? [] : [for i in origin.value.custom_header : {
          name  = i.name
          value = i.value
        }]
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
      dynamic "s3_origin_config" {
        for_each = origin.value.identity == null ? [] : [origin.value.identity]
        content {
          origin_access_identity = s3_origin_config.value
        }
      }
    }
  }

  dynamic "origin" {
    for_each = [for i in var.custom_origin_config : {
      name                     = i.domain_name
      id                       = i.origin_id
      path                     = lookup(i, "origin_path", "")
      http_port                = lookup(i, "http_port", 80)
      https_port               = lookup(i, "https_port",443)
      origin_keepalive_timeout = lookup(i, "origin_keepalive_timeout", 60)
      origin_read_timeout      = lookup(i, "origin_read_timeout", 60)
      origin_protocol_policy   = lookup(i, "origin_protocol_policy","https-only")
      origin_ssl_protocols     = lookup(i, "origin_ssl_protocols", ["TLSv1.2"])
      custom_header            = lookup(i, "custom_header", null)
      origin_shield            = lookup(i, "origin_shield", {})
    }]
    content {
      domain_name = origin.value.name
      origin_id   = origin.value.id
      origin_path = origin.value.path
      dynamic "custom_header" {
        for_each = origin.value.custom_header == null ? [] : [for i in origin.value.custom_header : {
          name  = i.name
          value = i.value
        }]
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
      custom_origin_config {
        http_port                = origin.value.http_port
        https_port               = origin.value.https_port
        origin_keepalive_timeout = origin.value.origin_keepalive_timeout
        origin_read_timeout      = origin.value.origin_read_timeout
        origin_protocol_policy   = origin.value.origin_protocol_policy
        origin_ssl_protocols     = origin.value.origin_ssl_protocols
      }
      dynamic "origin_shield" {
        for_each = length(keys(origin.value.origin_shield)) == 0 ? [] : [lookup(origin.value, "origin_shield", {})]
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = [for i in var.origin_group : {
      id           = i.origin_id
      status_codes = i.status_codes
      member       = lookup(i, "member", null)
    }]
    content {
      origin_id = origin_group.value.id
      failover_criteria {
        status_codes = origin_group.value.status_codes
      }
      dynamic "member" {
        for_each = origin_group.value.member == null ? [] : [for i in origin_group.value.member : {
          id = i.origin_id
        }]
        content {
          origin_id = member.value.id
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods    = var.allowed_methods
    cached_methods     = var.cached_methods
    cache_policy_id    = var.cache_policy_id
    target_origin_id   = var.target_origin_id
    compress           = var.compress
    trusted_signers    = var.trusted_signers
    trusted_key_groups = var.trusted_key_groups

    dynamic "forwarded_values" {
      # If a cache policy is specified, we cannot include a `forwarded_values` block at all in the API request
      for_each = var.cache_policy_id == null ? [true] : []
      content {
        query_string            = var.forward_query_string
        query_string_cache_keys = var.query_string_cache_keys
        headers                 = var.forward_header_values

        cookies {
          forward = var.forward_cookies
        }
      }
    }

    viewer_protocol_policy  = var.viewer_protocol_policy
    default_ttl             = var.default_ttl
    min_ttl                 = var.min_ttl
    max_ttl                 = var.max_ttl
    realtime_log_config_arn = var.realtime_log_config_arn

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_association
      content {
        event_type   = lambda_function_association.value.event_type
        include_body = lookup(lambda_function_association.value, "include_body", null)
        lambda_arn   = lambda_function_association.value.lambda_arn
      }
    }

    dynamic "function_association" {
      for_each = var.function_association
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      compress               = lookup(ordered_cache_behavior.value, "compress", null)
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      cache_policy_id          = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
      origin_request_policy_id = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)

      min_ttl     = lookup(ordered_cache_behavior.value, "min_ttl", null)
      default_ttl = lookup(ordered_cache_behavior.value, "default_ttl", null)
      max_ttl     = lookup(ordered_cache_behavior.value, "max_ttl", null)

      dynamic "forwarded_values" {
        for_each = lookup(ordered_cache_behavior.value, "use_forwarded_values", true) ? [true] : []
        content {
          query_string = lookup(ordered_cache_behavior.value, "query_string", null)
          headers      = lookup(ordered_cache_behavior.value, "headers", null)

          cookies {
            forward = lookup(ordered_cache_behavior.value, "cookies_forward", null)
          }
        }
      }

      dynamic "lambda_function_association" {
        iterator = lambda
        for_each = lookup(ordered_cache_behavior.value, "lambda_function_association", [])
        content {
          event_type   = lambda.value.event_type
          lambda_arn   = lambda.value.lambda_arn
          include_body = lookup(lambda.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        iterator = cffunction
        for_each = lookup(ordered_cache_behavior.value, "function_association", [])
        content {
          event_type   = cffunction.value.event_type
          function_arn = cffunction.value.function_arn
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response

    content {
      error_code            = custom_error_response.value.error_code
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_config[*]

    content {
      bucket          = logging_config.value.bucket
      include_cookies = lookup(logging_config.value, "include_cookies", null)
      prefix          = lookup(logging_config.value, "prefix", null)
    }
  }

  tags = merge({ "Provisioned" = "Terraform" }, var.tags)

  restrictions {
    geo_restriction {
      locations        = var.restriction_location
      restriction_type = var.restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.acm_certificate_arn == null ? true : false
    ssl_support_method             = var.acm_certificate_arn == null ? null : "sni-only"
    minimum_protocol_version       = var.acm_certificate_arn == null ? "TLSv1" : var.minimum_protocol_version
  }
}