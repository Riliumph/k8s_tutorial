resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "eks-igw"
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnet

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = "${var.region}${each.value.az}"
  map_public_ip_on_launch = each.value.public
  tags = {
    Name = each.value.public ? "eks-pub-subnet-${each.value.az}" : "eks-pri-subnet-${each.value.az}"
  }
}

#===================================================================
# Route Table

#===================================================================
# Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "eks-public-rt"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in var.subnet : k => v
    if v.public
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

#===================================================================
# Private Route Table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "eks-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = {
    for k, v in var.subnet : k => v
    if !v.public
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private.id
}
