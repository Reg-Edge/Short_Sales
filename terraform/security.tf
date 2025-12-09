# security.tf
# Security group: no inbound, outbound HTTPS only
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

resource "aws_security_group" "main" {
  name        = "pbisg"
  description = "No inbound, outbound HTTPS only"
  vpc_id      = aws_vpc.main.id
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "pbisg" })
}
