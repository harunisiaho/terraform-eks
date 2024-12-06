output "arn" {
    value = aws_alb.alb.arn
}

output "aws_alb_security_group_id" {
    value = aws_security_group.alb_sg.id
}