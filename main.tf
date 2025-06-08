# === PROVIDERS ===
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

provider "aws" {
  alias  = "california"
  region = "us-west-1"
}

# === ORIGIN ACCESS IDENTITY ===
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Access Identity for S3 static sites"
}


# === Virginia S3 Bucket ===
resource "aws_s3_bucket" "virginia" {
  provider = aws.virginia
  bucket   = local.virginia_lab_bucket

  website {
    index_document = "virginia.html"
  }
  tags = {
    Region = "us-east-1"
  }
}

resource "aws_s3_bucket_policy" "virginia_policy" {
  bucket = aws_s3_bucket.virginia.id
  policy = data.aws_iam_policy_document.virginia_policy.json
}

data "aws_iam_policy_document" "virginia_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.account_id}-mini-lab-cf-virginia/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }

    effect = "Allow"
  }
}

resource "aws_s3_object" "virginia_html" {
  provider = aws.virginia
  bucket   = aws_s3_bucket.virginia.id
  key      = "virginia.html"
  source   = "/home/peteroms/AWS_P1/DR/virginia.html"
  content_type = "text/html"
  
}


# === California S3 Bucket ===
resource "aws_s3_bucket" "california" {
  provider = aws.california
  bucket   = local.california_lab_bucket
    website {
        index_document = "california.html"
    }
    tags = {
        Region = "us-west-1"
    }
}
resource "aws_s3_bucket_policy" "california_policy" {
  bucket = aws_s3_bucket.california.id
  policy = data.aws_iam_policy_document.california_policy.json

  provider = aws.california
}

data "aws_iam_policy_document" "california_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.account_id}-mini-lab-cf-california/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }

    effect = "Allow"
  }
}

resource "aws_s3_object" "california_html" {
  provider = aws.california
  bucket   = aws_s3_bucket.california.id
  key      = "california.html"
  source   = "/home/peteroms/AWS_P1/DR/california.html"
  content_type = "text/html"
  
}
