resource "aws_lb" "web_app" {
  name               = "lb-${random_string.lb_id.result}-${local.name_suffix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.aws_security_group.web_app_alb.id]
  subnets            = module.vpc.public_subnets

  tags = local.tags


}

resource "aws_lb_listener" "web_app" {
  load_balancer_arn = aws_lb.web_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app.arn
  }
  tags = local.tags
}


resource "aws_lb_target_group" "web_app" {
  name                 = "lb-target-grp-${local.name_suffix}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
  }
  tags = local.tags
}
