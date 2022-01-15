module "web_server"{
    source ="./http_server"
    instance_type = "t3.micro"
}

output "public_dns"{
    value = module.web_server.public_dns
}


resource "aws_s3_bucket" "private" {
    bucket = "private-pragmatic-terraform20220115"

    versioning {
        enabled = true
    }

    server_side_encryption_configuration{
        rule{
            apply_server_side_encryption_by_default{
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_s3_bucket_public_access_block" "private"{
    bucket = aws_s3_bucket.private.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket" "public" {
    bucket = "public-pragmatic-terraform-20220115"
    acl = "public-read"

    cors_rule {
        allowed_origins = ["https://example.com"]
        allowed_methods = ["GET"]
        allowed_headers = ["*"]
        max_age_seconds = 3000
    }
}

resource "aws_s3_bucket" "alb_log" {
    bucket = "alb-log-pragmatic-terraform20220115"

    lifecycle_rule {
        enabled = true

        expiration {
            days = "180"
        }
    }
}
