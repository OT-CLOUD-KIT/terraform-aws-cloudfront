# Terraform AWS DocumentDB Cluster Module
[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png


**This README.md provides a comprehensive guide to setting up and managing CloudFront distributions using Terraform, making it easier for users to understand.**

***

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Usage](#usage)
- [Use Cases](#UseCases)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Contact Information](#contact-information)
- [References](#References)



## Introduction

A content delivery network (CDN) is a network of interconnected servers that speeds up webpage loading for data-heavy applications.This project involves setting up Amazon CloudFront distributions using Terraform for automated infrastructure management.

## Features

| Feature                              | Description                                                                 |
|--------------------------------------|-----------------------------------------------------------------------------|
| **Custom Aliases (CNAMEs)**          | Configure custom domain names for your CloudFront distributions.            |
| **TLS/SSL Configuration**            | Secure your content with SSL/TLS certificates managed by AWS.               |
| **Origin Configuration**             | Set up origins such as S3 buckets or custom servers for content delivery.   |
| **Cache Policies**                   | Optimize content delivery with configurable cache settings.                 |
| **Access Control**                   | Use signed URLs or cookies to restrict access to content.                   |

## Usage

### main.tf file

<details>
<summary> <b> Click here for main.tf file </b> </summary>
<br>
    
```shell
resource "aws_cloudfront_distribution" "this" {
  for_each = var.cloudfront_distributions
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
   
```
</details>

### output.tf file

<details>
<summary> <b> Click here for output.tf file </b> </summary>
<br>

```shell
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


```
</details>

### variables.tf file

<details>
<summary> <b> Click here for variables.tf file </b> </summary>
<br>

```shell
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

```
</details>

### terraform.tfvars file

<details>
<summary> Click here to see terraform.tfvars file</summary>
<br>
    
```shell
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

```
</details>


***

## Use Cases:

1- [Setup of Cloud Front without acm certificate and with default policies](https://github.com/OT-CLOUD-KIT/terraform-aws-cloudfront/pull/3/files#diff-658c342d224fc04f977353d24a46f9e0f0d5b18c85d922e7c5234971717fd7bb)

  This example demonstrates a basic setup of AWS CloudFront using Terraform without **acm certificate arn** and with default **policies**. It covers essential configurations to get started with CloudFront in your AWS environment.

2- [Setup of Cloud Front with acm certificate and with default policies](https://github.com/OT-CLOUD-KIT/terraform-aws-documentdb/tree/documentDB/examples/secured_with_kms_key)

This example demonstrates a basic setup of AWS CloudFront using Terraform with **acm certificate arn** and with default **policies**. It covers essential configurations to get started with CloudFront in your AWS environment


***

## Inputs

| Name                 | Description                                                       | Type     | Required |
|----------------------|-------------------------------------------------------------------|----------|--------- | 
| **cloudfront_distributions** | Distribution name for cloudfront                          | string   |  yes     |
| **cloudfront_cache_policies** | Cache Policy for cloudfront                              | string   | yes      |
| **cloudfront_origin_request_policies** | Request policy for cloudfront                   | string   | yes      |
| **cloudfront_response_headers_policies** | Response Header policy for cloudfront         | string   | yes      |
| **cloudfront_origin_access_controls** | Origin Access control (origin type, behavior,etc)| string   | yes      |

***

## Outputs

| Name | Description |
|------|-------------|
| **cloudfront_cache_policies_id** | Cache Policy Id. |
| **cloudfront_distributions_id** | CloudFront Distribution ID. |
| **cloudfront_distributions_arn** | CloudFront Distribution arn. |
| **cloudfront_request_policies_id** | Request Policy ID. |
| **cloudfront_headers_policies_id** | Header Policy ID. |

***

## Contact Information

| **Name** | **Email Address** |
| -------- | ----------------- |
| **Shreya Jaiswal** | shreya.jaiswal@mygurukulam.co |

***

# References

| **Source** | **Description** |
| ---------- | --------------- |
| [Link](https://aws.amazon.com/what-is/cdn/#:~:text=A%20content%20delivery%20network%20CDN,loading%20for%20data%2Dheavy%20applications) | CloudFront Concept. |
| [Link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | Reference Link For Terraform Modules. |
