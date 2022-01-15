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

resource "aws_vpc" "example"{
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "example"
    }
}

resource "aws_subnet" "public_0"{
    vpc_id = aws_vpc.example.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-1a"
    tags = {
        Name = "public"
    }
}

resource "aws_subnet" "public_1"{
    vpc_id = aws_vpc.example.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-1c"
}

resource "aws_internet_gateway" "example"{
    vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "public"{
    vpc_id = aws_vpc.example.id
}

resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    gateway_id = aws_internet_gateway.example.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_0"{
    subnet_id = aws_subnet.public_0.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1"{
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_0"{
    vpc_id = aws_vpc.example.id
    cidr_block = "10.0.64.0/24"
    availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "private_1"{
    vpc_id = aws_vpc.example.id
    cidr_block = "10.0.65.0/24"
    availability_zone = "ap-northeast-1c"
    map_public_ip_on_launch = false
}

resource "aws_route_table" "private_0"{
    vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "private_1"{
    vpc_id = aws_vpc.example.id
}

resource "aws_eip" "nat_gateway_0"{
    vpc = true
    depends_on = [aws_internet_gateway.example]
}

resource "aws_eip" "nat_gateway_1"{
    vpc = true
    depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway_0"{
    allocation_id = aws_eip.nat_gateway_0.id
    subnet_id = aws_subnet.public_0.id
    depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway_1"{
    allocation_id = aws_eip.nat_gateway_1.id
    subnet_id = aws_subnet.public_1.id
    depends_on = [aws_internet_gateway.example]
}

resource "aws_route" "private_0"{
    route_table_id = aws_route_table.private_0.id
    nat_gateway_id = aws_nat_gateway.nat_gateway_0.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1"{
    route_table_id = aws_route_table.private_1.id
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_0"{
    route_table_id = aws_route_table.private_0.id
    subnet_id = aws_subnet.private_0.id
}

resource "aws_route_table_association" "private_1"{
    route_table_id = aws_route_table.private_1.id
    subnet_id = aws_subnet.private_1.id
}

module "example_sg"{
    source = "./security_group"
    name = "module-sg"
    vpc_id = aws_vpc.example.id
    port = 80
    cidr_blocks = ["0.0.0.0/0"]
}