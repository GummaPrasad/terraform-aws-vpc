data "aws_availability_zones" "available" {
    state = "available"
}

locals {
    common_tags = {
        Name        = var.project_name
        Environment = var.environment
        Owner       = var.owner
    }
    common_name_suffix = "${var.project_name}-${var.environment}"
    az_names = slice(data.aws_availability_zones.available.names, 0, 2)
}
