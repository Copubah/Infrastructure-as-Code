terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "app_bucket" {
    bucket = var.bucket_app

}
 resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.app_bucket.id
    key = "index.html"
    source = "website/index.html"
    etag = filemd5("website/index.html")
    content = "text/html"
 }

 resource "aws_s3_object" "error_html" {
    bucket = aws_s3_bucket.app_bucket.id
    key = "error.html"
    source = "website/error.html"
    etag = filemd5("website/error.html")
    content = "text/html"
 }

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "Origin Access Identity for static website"
  
}


 resource "aws_cloudfront_distribution" "cloudfront_dist" {
    origin {
      domain_name = aws_s3_bucket.app_bucket.bucket_regional_domain_name
      origin_id = var.bucket_regional_domain_name

      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.caller_reference.
        cloudfront_access_identity_path 
      }
    }
    enabled = true
    is_ipv6_enabled = true
    default_root_object = var.website_index_document

    default_cache_behavior {
    allowed_methods  = ["GET", "HEAD",]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = var.bucket_app
    }
   
 }

