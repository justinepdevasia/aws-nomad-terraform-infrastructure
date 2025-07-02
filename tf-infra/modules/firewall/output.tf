output "server_alb_security_group_id" {
    value = aws_security_group.server_alb_security_group.id
}

output "client_alb_security_group_id" {
    value = aws_security_group.client_alb_security_group.id
}

output "ec2_security_group_id" {
    value = aws_security_group.ec2_security_group.id
}

output "postgres_security_group_id" {
    value = aws_security_group.postgres_security_group.id
}