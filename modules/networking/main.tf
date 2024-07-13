data "aws_vpc" "vpc" {
  id = var.vpc_id
}
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_subnet" "priv_subnet" {
  count                = var.priv_subnet_count
  cidr_block           = "172.31.${local.priv_cidr_index_fix[count.index]}.0/24"
  vpc_id               = data.aws_vpc.vpc.id
  availability_zone_id = "use1-az${count.index + 1}"

  tags = {
    Name = "${terraform.workspace}-privsubnet-${count.index}"
  }
}


resource "aws_subnet" "pub_subnet" {
  count                = 2
  cidr_block           = "172.31.${local.pub_cidr_index_fix[count.index]}.0/24"
  vpc_id               = data.aws_vpc.vpc.id
  availability_zone_id = "use1-az${count.index + 1}"

  tags = {
    Name = "${terraform.workspace}-pubsubnet-${count.index}"
  }
}

resource "aws_eip" "eip" {
  count = 2
}

resource "aws_nat_gateway" "ngw" {
  count         = 1
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub_subnet[count.index].id

  tags = {
    Name = "${terraform.workspace}-nat-gateway-${count.index}"
  }
}

resource "aws_route_table" "pub_subnet_rt" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = data.aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "priv_subnet_rt" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = data.aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[0].id
  }
}

resource "aws_route_table_association" "priv_rt_assoc" {
  count          = var.priv_subnet_count
  subnet_id      = aws_subnet.priv_subnet[count.index].id
  route_table_id = aws_route_table.priv_subnet_rt.id
}

resource "aws_route_table_association" "pub_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.pub_subnet[count.index].id
  route_table_id = aws_route_table.pub_subnet_rt.id
}
