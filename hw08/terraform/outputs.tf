output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.nginx.dns_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL for the nginx image"
  value       = aws_ecr_repository.mynginx.repository_url
}
