resource "aws_security_group" "alb_sg" {
    name = "${var.alb_name}-sg"
    vpc_id = var.vpc_id

    tags = {
      "Name" = "${var.alb_name}-sg"
    }
}

resource "aws_alb" "alb" {
    name = var.alb_name
    security_groups = [aws_security_group.alb_sg.id]
    subnets = var.public_subnet_ids
    tags = {
        Name = var.alb_name
    }
    # access_logs {
    #     bucket = var.alb_logs_bucket_name
    #     prefix = "alb"
    #     enabled = true
    # }
}