variable "bucket_name" {}
variable "Environment" {}

terraform {
  backend "s3" {
    bucket         = "testasdawf4115154"
    key            = "terraform.tfstate"
    region         = "us-east-1"
   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}


resource "aws_s3_bucket" "s3_bucket" {

   bucket = var.bucket_name
   force_destroy = true
   object_lock_enabled = false 
   tags = {
    Name        = "bucket"
    Environment = var.Environment
  }

}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}


resource "aws_s3_bucket_ownership_controls" "Bucketowner" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "expiration-7days" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id = "rule-1" 
    status = "Enabled" 
    expiration {
      days = 7
    }

  }
}

resource "aws_s3_bucket_versioning" "versioning_enable" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
