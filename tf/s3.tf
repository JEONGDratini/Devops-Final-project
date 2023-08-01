# 1. S3 

# S3 버킷 생성
resource "aws_s3_bucket" "terraform-mk2"{
  bucket = "terraform-hoon"
}

# acl
resource "aws_s3_bucket_acl" "terraform-mk2-acl" {
  bucket = aws_s3_bucket.terraform-mk2.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# ownership
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.terraform-mk2.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}


# 파일 업로드
  ## login.html 
resource "aws_s3_bucket_object" "object_login"{
  bucket = aws_s3_bucket.terraform-mk2.id
  key    = "login.html"
  content_type = "text/html"
  source = "login.html"
}
  ## task.html
resource "aws_s3_bucket_object" "object_task"{
  bucket = aws_s3_bucket.terraform-mk2.id
  key    = "task.html"
  content_type = "text/html"
  source = "task.html"
}
  ## error.html
resource "aws_s3_bucket_object" "object_error"{
  bucket = aws_s3_bucket.terraform-mk2.id
  key    = "error.html"
  content_type = "text/html"
  source = "error.html"
}

# IAM 정책 
data "aws_iam_policy_document" "s3_iam_policy"{
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutBucketAcl",
      "s3:PutBucketPolicy",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.terraform-mk2.arn}/*"]
  }
}

# iam user
# resource "aws_iam_user" "hoonology" {
#   name = "iam-hoonology"
# }

# 퍼블릭 접근 차단
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.terraform-mk2.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 버킷 정책
resource "aws_s3_bucket_policy" "terraform-mk2-policy"{
  bucket = aws_s3_bucket.terraform-mk2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform-mk2.id}",
          "arn:aws:s3:::${aws_s3_bucket.terraform-mk2.id}/*"
        ]
      },
      {
        Sid = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform-mk2.id}",
          "arn:aws:s3:::${aws_s3_bucket.terraform-mk2.id}/*"
        ]
      },
    ]
  })
  
  depends_on = [aws_s3_bucket_public_access_block.example]
}


# Cors 정책
resource "aws_s3_bucket_cors_configuration" "terraform-mk2-cors" {
  bucket = aws_s3_bucket.terraform-mk2.id 

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
  }
}

