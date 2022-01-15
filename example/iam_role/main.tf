variable "name" {}
variable "policy" {}
variable "identifier" {}

resource "aws_iam_role" "default" {
    name = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role"{
    statement{
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = [var.identifier]
        }
    }
}

output "iam_role_name" {
    value = aws_iam_role.default.name
}