resource "aws_route53_zone" "primary" {
  name = var.domain

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-aws"
    Domain      = var.domain
  }
}

resource "aws_route53_record" "server_ip" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain
  type    = "A"
  ttl     = "300"
  records = [var.server_public_ip]
}
