# Terraform AWS CloudFront



A Terraform module to create a fully configurable and production-ready AWS CloudFront distribution with support for S3 and custom origins, caching policies, WAF integration, Lambda@Edge, error handling, and more.



## Architecture
![cloud_front drawio](https://github.com/user-attachments/assets/8f66f766-8706-45ca-8053-2893ff016ece)


> **Note:**  
> The diagram represents a highly flexible CloudFront setup with multiple origins (S3 and custom)

---


## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2   |
| <a name="terraform_module"></a> [Terraform](Terraform\module) | >= 1.12.1|


## Usage

```hcl
module "network" {
  source                               = "../"
  cloudfront_distributions             = var.cloudfront_distributions
  cloudfront_cache_policies            = var.cloudfront_cache_policies
  cloudfront_origin_request_policies   = var.cloudfront_origin_request_policies
  cloudfront_response_headers_policies = var.cloudfront_response_headers_policies
  cloudfront_origin_access_controls    = var.cloudfront_origin_access_controls
}
```



### Resources

| Resource | Description |
|----------|-------------|
| [`aws_cloudfront_distribution`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | Manages a CloudFront distribution, including cache behaviors, origins, and viewer certificates. |
| [`aws_cloudfront_cache_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | Defines how CloudFront caches content based on request parameters like headers, cookies, and query strings. |
| [`aws_cloudfront_origin_request_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | Controls which headers, cookies, and query strings CloudFront includes in requests sent to the origin. |
| [`aws_cloudfront_response_headers_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | Sets CORS, security, and custom headers in responses returned from CloudFront. |
| [`aws_cloudfront_origin_access_control`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | Manages CloudFront origin access control configuration (used to access S3 securely). |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_target_origin_id"></a> [target_origin_id](#input_target_origin_id) | The ID for the origin that CloudFront routes requests to. | `string` | `n/a` | yes |
| <a name="input_acm_certificate_arn"></a> [acm_certificate_arn](#input_acm_certificate_arn) | The ACM certificate ARN (must be in `us-east-1`). | `string` | `null` | no |
| <a name="input_alias"></a> [alias](#input_alias) | CNAMES/aliases for the distribution. | `list` | `[]` | no |
| <a name="input_comment"></a> [comment](#input_comment) | Optional comment for the distribution. | `string` | `""` | no |
| <a name="input_cloudfront_default_certificate"></a> [cloudfront_default_certificate](#input_cloudfront_default_certificate) | Backward-compatible default certificate setting. | `bool` | `true` | no |
| <a name="input_default_root_object"></a> [default_root_object](#input_default_root_object) | Default object returned when root URL is requested. | `string` | `""` | no |
| <a name="input_custom_error_response"></a> [custom_error_response](#input_custom_error_response) | Custom error responses in dynamic block. | `any` | `[]` | no |
| <a name="input_custom_origin_config"></a> [custom_origin_config](#input_custom_origin_config) | Configuration for custom origin. | `any` | `[]` | no |
| <a name="input_ordered_cache_behavior"></a> [ordered_cache_behavior](#input_ordered_cache_behavior) | Ordered cache behaviors in dynamic block. | `any` | `[]` | no |
| <a name="input_origin_group"></a> [origin_group](#input_origin_group) | Origin groups in dynamic block. | `any` | `[]` | no |
| <a name="input_logging_config"></a> [logging_config](#input_logging_config) | Logging configuration for the distribution. | `any` | `[]` | no |
| <a name="input_s3_origin_config"></a> [s3_origin_config](#input_s3_origin_config) | S3 origin configuration block. | `list(map(string))` | `[]` | no |
| <a name="input_enable"></a> [enable](#input_enable) | Whether the distribution is enabled. | `bool` | `true` | no |
| <a name="input_is_ipv6_enabled"></a> [is_ipv6_enabled](#input_is_ipv6_enabled) | Whether IPv6 is enabled. | `bool` | `false` | no |
| <a name="input_http_version"></a> [http_version](#input_http_version) | Maximum supported HTTP version. | `string` | `http2` | no |
| <a name="input_iam_certificate_id"></a> [iam_certificate_id](#input_iam_certificate_id) | IAM certificate ID for CloudFront. | `string` | `null` | no |
| <a name="input_minimum_protocol_version"></a> [minimum_protocol_version](#input_minimum_protocol_version) | Minimum SSL protocol version to use. | `string` | `TLSv1` | no |
| <a name="input_price_class"></a> [price_class](#input_price_class) | The price class to use. | `string` | `PriceClass_All` | no |
| <a name="input_allowed_methods"></a> [allowed_methods](#input_allowed_methods) | Allowed HTTP methods for cache behavior. | `list(string)` | `["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]` | no |
| <a name="input_cached_methods"></a> [cached_methods](#input_cached_methods) | Cached HTTP methods. | `list(string)` | `["GET", "HEAD"]` | no |
| <a name="input_cache_policy_id"></a> [cache_policy_id](#input_cache_policy_id) | ID of the cache policy to attach. | `string` | `null` | no |
| <a name="input_default_ttl"></a> [default_ttl](#input_default_ttl) | Default TTL for objects in cache (seconds). | `number` | `60` | no |
| <a name="input_min_ttl"></a> [min_ttl](#input_min_ttl) | Minimum TTL for objects in cache. | `number` | `0` | no |
| <a name="input_max_ttl"></a> [max_ttl](#input_max_ttl) | Maximum TTL for objects in cache. | `number` | `31536000` | no |
| <a name="input_trusted_signers"></a> [trusted_signers](#input_trusted_signers) | List of AWS accounts allowed to sign URLs. | `list(string)` | `[]` | no |
| <a name="input_trusted_key_groups"></a> [trusted_key_groups](#input_trusted_key_groups) | Key groups used for signed URLs/cookies. | `list(string)` | `[]` | no |
| <a name="input_compress"></a> [compress](#input_compress) | Enable compression for gzip-encoded content. | `bool` | `true` | no |
| <a name="input_viewer_protocol_policy"></a> [viewer_protocol_policy](#input_viewer_protocol_policy) | Limit protocol access for users. | `string` | `redirect-to-https` | no |
| <a name="input_realtime_log_config_arn"></a> [realtime_log_config_arn](#input_realtime_log_config_arn) | ARN of real-time log configuration. | `string` | `null` | no |
| <a name="input_lambda_function_association"></a> [lambda_function_association](#input_lambda_function_association) | Lambda@Edge config for cache behavior. | `list(object)` | `[]` | no |
| <a name="input_function_association"></a> [function_association](#input_function_association) | CloudFront Function config. | `list(object)` | `[]` | no |
| <a name="input_forward_query_string"></a> [forward_query_string](#input_forward_query_string) | Forward query strings to the origin. | `bool` | `false` | no |
| <a name="input_query_string_cache_keys"></a> [query_string_cache_keys](#input_query_string_cache_keys) | List of query string keys to cache. | `list(string)` | `[]` | no |
| <a name="input_forward_cookies"></a> [forward_cookies](#input_forward_cookies) | Specify whether to forward all or no cookies. | `list(string)` | `[]` | no |
| <a name="input_forward_header_values"></a> [forward_header_values](#input_forward_header_values) | Whitelisted headers to forward. | `list(string)` | `["Accept", "Host", "Origin"]` | no |
| <a name="input_restriction_location"></a> [restriction_location](#input_restriction_location) | ISO codes for geolocation restriction. | `list(string)` | `[]` | no |
| <a name="input_restriction_type"></a> [restriction_type](#input_restriction_type) | Restriction type (none, whitelist, blacklist). | `string` | `"none"` | no |
| <a name="input_retain_on_delete"></a> [retain_on_delete](#input_retain_on_delete) | Keep distribution after destroy. | `bool` | `false` | no |
| <a name="input_ssl_support_method"></a> [ssl_support_method](#input_ssl_support_method) | SSL support method. | `string` | `sni-only` | no |
| <a name="input_tag_name"></a> [tag_name](#input_tag_name) | Tag for the distribution. | `string` | `n/a` | no |
| <a name="input_wait_for_deployment"></a> [wait_for_deployment](#input_wait_for_deployment) | Wait for status to become "Deployed". | `bool` | `true` | no |
| <a name="input_webacl"></a> [webacl](#input_webacl) | WAF Web ACL for the distribution. | `string` | `""` | no |



## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_cache_policies_id"></a> [cloudfront_cache_policies_id](#output_cloudfront_cache_policies_id) | CloudFront Cache Policy IDs |
| <a name="output_cloudfront_distributions_id"></a> [cloudfront_distributions_id](#output_cloudfront_distributions_id) | CloudFront Distribution IDs |
| <a name="output_cloudfront_distributions_arn"></a> [cloudfront_distributions_arn](#output_cloudfront_distributions_arn) | CloudFront Distribution ARNs |
| <a name="output_cloudfront_request_policies_id"></a> [cloudfront_request_policies_id](#output_cloudfront_request_policies_id) | CloudFront Origin Request Policy IDs |
| <a name="output_cloudfront_headers_policies_id"></a> [cloudfront_headers_policies_id](#output_cloudfront_headers_policies_id) | CloudFront Response Headers Policy IDs |



