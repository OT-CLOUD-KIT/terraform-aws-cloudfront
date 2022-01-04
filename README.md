# ot-cloudfront

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/200x100/https://www.opstree.com/images/og_image8.jpg
  - This terraform module will create a complete Cloudfront setup.
  - This project is a part of opstree's ot-aws initiative for terraform modules.

# What is Cloudfront?
Amazon CloudFront is a fast content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency, high transfer speeds, all within a developer-friendly environment.

## Usage

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Example usage code
module cloudfront {
source  = "./OT-CLOUDFRONT/"    
comment                  = "AWS Cloudfront Module"
webacl = <WAF_ACL_ID>
target_origin_id = <assign target_origin_id for default cache>
s3_origin_config = [
  {
    domain_name            = "domain.s3.amazonaws.com"
    origin_id              = "S3-domain-cert"
    origin_access_identity = "origin-access-identity/cloudfront/1234"
  }
]
custom_origin_config = [
  {
    domain_name              = "sample.com"
    origin_id                = "sample"
    origin_path              = ""
    http_port                = 80
    https_port               = 443
    origin_keepalive_timeout = 5
    origin_read_timeout      = 30
    origin_protocol_policy   = "https-only"
    origin_ssl_protocols     = ["TLSv1.2", "TLSv1.1"]
  }
]
ordered_cache_behavior = [
  {
    path_pattern           = "/sample/"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "sample.com"
    compress               = false
    query_string           = true
    cookies_forward        = "all"
    headers                = []
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
]
custom_error_response = [
  {
    error_caching_min_ttl = 1
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error/200.html"
  }
]
}

```

## Inputs

| Name | Description | Type | Default | Required | Supported |
|------|-------------------|:----:|---------|:--------:|:---------:|
| target_origin_id |  The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior. | `string` |  | yes | |
| acm_certificate_arn | The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution. The ACM certificate must be in US-EAST-1 | `string` | `null` | no | |
| alias | Aliases, or CNAMES, for the distribution | `list` | `[]` | no | |
| comment | Any comment about the CloudFront Distribution | `string` | `""` | no | |
| cloudfront_default_certificate | This variable is not required anymore, being auto generated, left here for compability purposes| `bool` | `true` | no | |
| default_root_object | The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL | `string` | `""` | no | |
| custom_error_response | Custom error response to be used in dynamic block |`any` | `[]`| no | |
| custom_origin_config | Configuration for the custom origin config to be used in dynamic block |`any` | `[]` | `no` | |
| ordered_cache_behavior | Ordered Cache Behaviors to be used in dynamic block | `any` | `[]` | no | |
| origin_group | Origin Group to be used in dynamic block | `any` | `[]` | no |  |
| logging_config | This is the logging configuration for the Cloudfront Distribution.  It is not required.     If you choose to use this configuration, be sure you have the correct IAM and Bucket ACL     rules.  Your tfvars file should follow this syntax:<br><br>    logging_config = [{     bucket = "<your-bucket>"     include_cookies = <true or false>     prefix = "<your-bucket-prefix>"     }] | `any` | `[]` | no | |
| s3_origin_config  | Configuration for the s3 origin config to be used in dynamic block | `list(map(string))` | `[]` | no | |
| enable | Whether the distribution is enabled to accept end user requests for content | `bool` | `true` | no | `` |
| is_ipv6_enabled | Whether the IPv6 is enabled for the distribution | `bool` | `false` | no | `` |
| http_version | The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2 | `string` | `http2` | no | `` | 
| iam_certificate_id | Specifies IAM certificate id for CloudFront distribution | `string` | `null` | no | `` |
| minimum_protocol_version | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. One of SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016, TLSv1.2_2018 or TLSv1.2_2019. Default: TLSv1. NOTE: If you are using a custom certificate (specified with acm_certificate_arn or iam_certificate_id), and have specified sni-only in ssl_support_method, TLSv1 or later must be specified. If you have specified vip in ssl_support_method, only SSLv3 or TLSv1 can be specified. If you have specified cloudfront_default_certificate, TLSv1 must be specified. | `string` | `TLSv1` | no | |
| price_class | The price class of the CloudFront Distribution. Valid types are PriceClass_All, PriceClass_100, PriceClass_200 | `string` | `PriceClass_All` | no | |
| allowed_methods | Default cache behaviour List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront | `list(string)` | `["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]` | no | |
| cached_methods | Default cache behaviour List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD) | `list(string)` | `["GET", "HEAD"]` | no | |
| cache_policy_id | The unique identifier of the existing cache policy to attach to the default cache behavior. If not provided, this module will add a default cache policy using other provided inputs. | `string` | `null` | no | |
| default_ttl | Default amount of time (in seconds) that an object is in a CloudFront cache | `number` | `60` | no | |
| min_ttl | Minimum amount of time that you want objects to stay in CloudFront caches | `number` | `0` | no | |
| max_ttl | Maximum amount of time (in seconds) that an object is in a CloudFront cache | `number` | `31536000` | no | |
| trusted_signers | The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable. | `list(string)` | `[]` | no | |
| trusted_key_groups | A list of key group IDs that CloudFront can use to validate signed URLs or signed cookies. | `list(string)` | `[]` | no | |
| compress | Compress content for web requests that include Accept-Encoding: gzip in the request header | `bool` | `true` | no | |
| viewer_protocol_policy | Limit the protocol users can use to access content. One of `allow-all`, `https-only`, or `redirect-to-https` | `string` | `redirect-to-https` | no | |
| realtime_log_config_arn | The ARN of the real-time log configuration that is attached to this cache behavior | `string` | `null` | no | |
| lambda_function_association | A config block that triggers a lambda@edge function with specific actions | `   list(object({     event_type = string       include_body = bool     lambda_arn = string     }]` | `[]` | no | |
| function_association | A config block that triggers a cloudfront function with specific actions | `   list(object({     event_type = string     function_arn = string    }]` | `[]` | no | |
| forward_query_string | Forward query strings to the origin that is associated with this cache behavior (incompatible with `cache_policy_id`) | `bool` | `false` | no | |
| query_string_cache_keys | When `forward_query_string` is enabled, only the query string keys listed in this argument are cached (incompatible with `cache_policy_id`) | `list(string)` | `[]` | no | |
| forward_cookies | Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none' | `list(string)` | `[]` | no | |
| forward_header_values | A list of whitelisted header values to forward to the origin (incompatible with `cache_policy_id`) | `list(string)` | `["Accept", "Host", "Origin"]` | no | |
| restriction\_location | The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist) | list | `[]` | no |
| restriction\_type | The restriction type of your CloudFront distribution geolocation restriction. Options include none, whitelist, blacklist | string | `"none"` | no |
| retain\_on\_delete | Disables the distribution instead of deleting it when destroying the resource through Terraform. If this is set, the distribution needs to be deleted manually afterwards. | bool | `false` | no |
| ssl\_support\_method | This variable is not required anymore, being auto generated, left here for compability purposes | string | sni-only | no |
| tag\_name | The tagged name | string | n/a | no |
| wait\_for\_deployment | If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process. | bool | `true` | no |
| webacl | The WAF Web ACL | string | `""` | no |



#

## Outputs

| Name | Description |  
|------|-------------|
| id | The identifier for the distribution. |
| arn | The ARN (Amazon Resource Name) for the distribution. |
| caller_reference | Internal value used by CloudFront to allow future updates to the distribution configuration. |
| status | The current status of the distribution. Deployed if the distribution's information is fully propagated throughout the Amazon CloudFront system. |
| trusted_signers | The key pair IDs that CloudFront is aware of for each trusted signer, if the distribution is set up to serve private content with signed URLs. |
| domain_name | The domain name corresponding to the distribution. For example: d902721fxabcqy9.cloudfront.net. |
| last_modified_time | The date and time the distribution was last modified. |
| in_progress_validation_batches | The number of invalidation batches currently in progress. |
| etag | The current version of the distribution's information. |
| hosted_zone_id | The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to. This attribute is simply an alias for the zone ID Z2FDTNDATAQYW2. |

#
## Contributors

[![Pawan Chandna][pawan_avatar]][pawan_homepage]<br/>[Pawan Chandna][pawan_homepage]

  [pawan_homepage]: https://gitlab.com/pawan.chandna
  [pawan_avatar]: https://img.cloudposse.com/75x75/https://gitlab.com/uploads/-/system/user/avatar/7777967/avatar.png?width=400
