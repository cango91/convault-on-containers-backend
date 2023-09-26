provider "aws" {
  region = "us-east-2"
}

resource "aws_route53_zone" "main" {
  name = "xn--glolu-jua30a.com."
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "convault.xn--glolu-jua30a.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.main.zone_id
  records = [each.value.record]
  ttl     = 60
}

resource "aws_instance" "chat_app_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_ecs_cluster" "chat_app_cluster" {
  name = "chat-app-cluster"
}

resource "aws_ecs_service" "chat_app_service" {
  name            = "chat-app-service"
  cluster         = aws_ecs_cluster.chat_app_cluster.id
  launch_type     = "EC2"
  desired_count   = 1
}