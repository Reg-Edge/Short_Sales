# ec2.tf
# EC2 instance with IMDSv2, SSM, user data for Power BI Desktop
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "pbi" {
  ami                         = data.aws_ami.windows2022.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  associate_public_ip_address = true
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }
  metadata_options {
    http_tokens = "required"
  }
  user_data = file("${path.module}/user_data.ps1")
  tags = merge(var.tags, { Name = "pbiec2" })
}
