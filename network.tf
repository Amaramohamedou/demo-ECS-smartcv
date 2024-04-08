#Creé un VPC
resource "aws_vpc" "vpc_smartcv" {
    cidr_block = "10.1.0.0/16"
    }

# Creé 4 public sous-réseaux

resource "aws_subnet" "subnet_smartcv_public_1" {
    vpc_id = aws_vpc.vpc_smartcv.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "us-west-2a"
    map_public_ip_on_launch = true
    }

resource "aws_subnet" "subnet_smartcv_public_2" {
    vpc_id = aws_vpc.vpc_smartcv.id
    cidr_block = "10.1.2.0/24"
    availability_zone = "us-west-2b"
    map_public_ip_on_launch = true
    }

# #################################################

# Creé 2 sous-réseaux privées avec NAT Gateway

resource "aws_subnet" "subnet_smartcv_private_1" {
    vpc_id = aws_vpc.vpc_smartcv.id
    cidr_block = "10.1.5.0/24"
    availability_zone = "us-west-2a"
}


resource "aws_subnet" "subnet_smartcv_private_2" {
    vpc_id = aws_vpc.vpc_smartcv.id
    cidr_block = "10.1.6.0/24"
    availability_zone = "us-west-2b"
}

# #################################################

# creé une NAT Gateway et une Elastic IP et une igw
resource "aws_eip" "eip_nat" {
domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.eip_nat.id
    subnet_id = aws_subnet.subnet_smartcv_public_1.id
}

resource "aws_internet_gateway" "igw_smartcv" {
    vpc_id = aws_vpc.vpc_smartcv.id
}

# #################################################


# Creé une route table pour les sous-réseaux publics et une route table pour les sous-réseaux privés


resource "aws_route_table" "route_table_public" {
    vpc_id = aws_vpc.vpc_smartcv.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_smartcv.id
        }
}

resource "aws_route_table" "route_table_private" {
    vpc_id = aws_vpc.vpc_smartcv.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
        }
}

# #################################################


#creé une association entre les sous-réseaux et les route tables

resource "aws_route_table_association" "route_table_association_public_1" {
    subnet_id = aws_subnet.subnet_smartcv_public_1.id
    route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "route_table_association_public_2" {
    subnet_id = aws_subnet.subnet_smartcv_public_2.id
    route_table_id = aws_route_table.route_table_public.id
}


resource "aws_route_table_association" "route_table_association_private_1" {
    subnet_id = aws_subnet.subnet_smartcv_private_1.id
    route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "route_table_association_private_2" {
    subnet_id = aws_subnet.subnet_smartcv_private_2.id
    route_table_id = aws_route_table.route_table_private.id
}

# #################################################

# Creé un groupe de sécurité pour les instances

resource "aws_security_group" "security_group" {
    name = "security_group"
    description = "Allow SSH and HTTP inbound traffic"
    vpc_id = aws_vpc.vpc_smartcv.id
    ingress {
        description = "SSH from VPC"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "HTTP from VPC"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# #################################################


# cree une application load balancer et un target group

resource "aws_lb_target_group" "smartcv_target_group" {
    name = "smartcv-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc_smartcv.id
}

resource "aws_lb_target_group_attachment" "target_group_attachment_svc" {
  target_group_arn = aws_lb_target_group.smartcv_target_group.arn
  target_id        = aws_ecs_service.svc_practice.id
  port             = 80
}

resource "aws_lb" "smartcv_lb" {
    name               = "smartcv-alb-practice"
    internal = false
    security_groups = [aws_security_group.security_group.id]
    load_balancer_type = "application"
    subnets            = [aws_subnet.subnet_smartcv_public_1.id, aws_subnet.subnet_smartcv_public_2.id]  # Replace with your subnet IDs
}

resource "aws_lb_listener" "alb_smartcv_listener" {
    load_balancer_arn = aws_lb.smartcv_lb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.smartcv_target_group.arn
    }
}


#add a part depends on to specify the order of creation of the resources