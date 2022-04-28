variable "acm_certificate_arn" {
  description = "The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. The ACM certificate must be in US-EAST-1."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of additional tags to attach"
  type        = map(string)
  default     = {}
}

variable "alias" {
  description = "Aliases, or CNAMES, for the distribution"
  type        = list(any)
  default     = []
}

variable "cloudfront_default_certificate" {
  description = "This variable is not required anymore, being auto generated, left here for compability purposes"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Any comment about the CloudFront Distribution"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
  type        = string
  default     = null
}

variable "custom_error_response" {
  description = "Custom error response to be used in dynamic block"
  type        = any
  default     = []
}

variable "custom_origin_config" {
  description = "Configuration for the custom origin config to be used in dynamic block"
  type        = any
  default     = []
}

variable "ordered_cache_behavior" {
  description = "Ordered Cache Behaviors to be used in dynamic block"
  type        = any
  default     = []
}

variable "origin_group" {
  description = "Origin Group to be used in dynamic block"
  type        = any
  default     = []
}

variable "logging_config" {
  description = <<EOF
    This is the logging configuration for the Cloudfront Distribution.  It is not required.
    If you choose to use this configuration, be sure you have the correct IAM and Bucket ACL
    rules.  Your tfvars file should follow this syntax:
    logging_config = [{
    bucket = "<your-bucket>"
    include_cookies = <true or false>
    prefix = "<your-bucket-prefix>"
    }]
    EOF

  type    = any
  default = []
}

variable "s3_origin_config" {
  description = "Configuration for the s3 origin config to be used in dynamic block"
  type        = any
  default     = []
}

variable "enable" {
  description = "Whether the distribution is enabled to accept end user requests for content"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution"
  type        = bool
  default     = false
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2"
  type        = string
  default     = "http2"
}

variable "iam_certificate_id" {
  description = "Specifies IAM certificate id for CloudFront distribution"
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = <<EOF
    The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections.
    One of SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016,TLSv1.2_2018 or TLSv1.2_2019. Default: TLSv1.
    NOTE: If you are using a custom certificate (specified with acm_certificate_arn or iam_certificate_id),
    and have specified sni-only in ssl_support_method, TLSv1 or later must be specified.
    If you have specified vip in ssl_support_method, only SSLv3 or TLSv1 can be specified.
    If you have specified cloudfront_default_certificate, TLSv1 must be specified.
    EOF

  type    = string
  default = "TLSv1"
}

variable "price_class" {
  description = "The price class of the CloudFront Distribution.  Valid types are PriceClass_All, PriceClass_100, PriceClass_200"
  type        = string
  default     = "PriceClass_All"
}

variable "restriction_location" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)"
  type        = list(any)
  default     = []
}

variable "restriction_type" {
  description = "The restriction type of your CloudFront distribution geolocation restriction. Options include none, whitelist, blacklist"
  type        = string
  default     = "none"
}

variable "retain_on_delete" {
  description = "Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards."
  type        = bool
  default     = false
}

variable "ssl_support_method" {
  description = "This variable is not required anymore, being auto generated, left here for compability purposes"
  type        = string
  default     = "sni-only"
}

variable "wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = true
}

variable "web_acl_id" {
  description = "The WAF Web ACL"
  type        = string
  default     = ""
}

// variable origin_group_member {
//   type = any
// }

##------------default cache behaviour variable-------------------------------
variable "allowed_methods" {
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront"
}

variable "cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)"
}

variable "cache_policy_id" {
  type        = string
  default     = null
  description = <<-EOT
    The unique identifier of the existing cache policy to attach to the default cache behavior.
    If not provided, this module will add a default cache policy using other provided inputs.
    EOT
}

variable "default_ttl" {
  type        = number
  default     = 60
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "min_ttl" {
  type        = number
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "max_ttl" {
  type        = number
  default     = 31536000
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "trusted_signers" {
  type        = list(string)
  default     = []
  description = "The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable."
}

variable "trusted_key_groups" {
  type        = list(string)
  default     = []
  description = "A list of key group IDs that CloudFront can use to validate signed URLs or signed cookies."
}

variable "compress" {
  type        = bool
  default     = true
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
}

variable "viewer_protocol_policy" {
  type        = string
  description = "Limit the protocol users can use to access content. One of `allow-all`, `https-only`, or `redirect-to-https`"
  default     = "redirect-to-https"
}

variable "realtime_log_config_arn" {
  type        = string
  default     = null
  description = "The ARN of the real-time log configuration that is attached to this cache behavior"
}

variable "lambda_function_association" {
  type = list(object({
    event_type   = string
    include_body = bool
    lambda_arn   = string
  }))

  description = "A config block that triggers a lambda@edge function with specific actions"
  default     = []
}

variable "function_association" {
  type = list(object({
    event_type   = string
    function_arn = string
  }))

  description = <<-EOT
    A config block that triggers a CloudFront function with specific actions.
    See the [aws_cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#function-association)
    documentation for more information.
  EOT
  default     = []
}
variable "forward_query_string" {
  type        = bool
  default     = false
  description = "Forward query strings to the origin that is associated with this cache behavior (incompatible with `cache_policy_id`)"
}

variable "query_string_cache_keys" {
  type        = list(string)
  description = "When `forward_query_string` is enabled, only the query string keys listed in this argument are cached (incompatible with `cache_policy_id`)"
  default     = []
}
variable "forward_cookies" {
  type        = string
  default     = "none"
  description = "Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none'"
}

variable "forward_header_values" {
  type        = list(string)
  description = "A list of whitelisted header values to forward to the origin (incompatible with `cache_policy_id`)"
  default     = ["Accept", "Host", "Origin"]
}

variable "target_origin_id" {
  type = string
}
