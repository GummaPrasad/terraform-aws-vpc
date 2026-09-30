### Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    var.vpc_tags,

    {
      Name = "${local.common_name_suffix}-vpc"
    }
  )
}

### Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.igw_vpc_tags,

    {
      Name = "${local.common_name_suffix}-igw"
    }
  )
}

### Create a public subnet in each availability zone
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true


  tags = merge(
    local.common_tags,
    var.public_subnet_tags,

    {
      Name = "${local.common_name_suffix}-public-subnet-${local.az_names[count.index]}"
    }
  )
}

### Create a private subnet in each availability zone
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]


  tags = merge(
    local.common_tags,
    var.private_subnet_tags,

    {
      Name = "${local.common_name_suffix}-private-subnet-${local.az_names[count.index]}"
    }
  )
}

### Create a database subnet in each availability zone
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]


  tags = merge(
    local.common_tags,
    var.database_subnet_tags,

    {
      Name = "${local.common_name_suffix}-database-subnet-${local.az_names[count.index]}"
    }
  )
}

### Create a route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.public_route_table_tags,

    {
      Name = "${local.common_name_suffix}-public-rt"
    }
  )
}

### Create a route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.private_route_table_tags,

    {
      Name = "${local.common_name_suffix}-private-rt"
    }
  )
}
### Create a route table for the database subnets
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.database_route_table_tags,

    {
      Name = "${local.common_name_suffix}-database-rt"
    }
  )
}
### Create a route for the public subnets to the Internet Gateway
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
### Create a NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-nat-gateway-eip"
    }
  )
}
### Create a NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    var.nat_gateway_tags,

    {
      Name = "${local.common_name_suffix}-nat-gateway"
    }
  )
  depends_on = [aws_internet_gateway.main]
}

### Create a route for the private subnets to the NAT Gateway
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
### Create a route for the database subnets to the NAT Gateway

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
### Create a route table association for each public subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
### Create a route table association for each private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
### Create a route table association for each database subnet
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}