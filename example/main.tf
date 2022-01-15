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

