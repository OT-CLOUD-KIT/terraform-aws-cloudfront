locals {
  origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
  origin_id              = aws_cloudfront_origin_access_identity.this.id
}
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.comment
}