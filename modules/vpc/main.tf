resource "aws_vpc" "main" {
  cidr_block = var.basic_cidr_block

  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_internet_gateway" "igs" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = var.igw_name
    }
  
}

resource "aws_eip" "nat-gw-eip" {
    tags = {
        Name = var.nat_gw_name
    }
  
}

resource "aws_nat_gateway" "nat-gw" {
    subnet_id = aws_subnet.public[0].id
    allocation_id = aws_eip.nat-gw-eip.id
    tags = {
        Name = "NAT-GW"
    }  
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igs.id
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gw.id
}
}

resource "aws_subnet" "public" {
    # Create one subnet for each availability zone
    count = length(var.aws_availability_zones)  

    #For each subnet, use the corresponding availability zone
    availability_zone = var.aws_availability_zones[count.index]

    #Specify VPCID
    vpc_id = aws_vpc.main.id

    map_public_ip_on_launch = true

    # Built-in functions and operators can be used for simple transformations of
    # values, such as computing a subnet address. Here we create a /20 prefix for
    # each subnet, using consecutive addresses for each availability zone,
    # such as 10.1.16.0/20 .
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index +1)
    
    tags = {
        Name = "public-subnet-${var.aws_availability_zones[count.index]}"
        "kubernetes.io/role/elb"	= 1
    }
}

resource "aws_subnet" "private" {
    count = length(var.aws_availability_zones)  

    availability_zone = var.aws_availability_zones[count.index]

    vpc_id = aws_vpc.main.id    
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(var.aws_availability_zones) + 1)
    tags = {
        Name = "private-subnet-${var.aws_availability_zones[count.index]}"
        "kubernetes.io/role/internal-elb"	= 1
    }
}

resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public)

    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private)

    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}