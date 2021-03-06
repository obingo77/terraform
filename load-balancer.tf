resource "aws_lb" "web_app" {
  //name               = "lb-${random_string.lb_id.result}-${local.name_suffix}"
  name               = trimsuffix(substr(replace(join("-", ["lb", random_string.lb_id.result, ]), "/[^a-zA-Z0-9-]/", ""), 0, 32), "-")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.lb_security_group.this_security_group_id]
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

resource "aws_lb_target_group_attachment" "web_app" {
  target_group_arn = aws_lb_target_group.web_app.arn
  target_id        = aws_instance.web_app[count.index].id
  count            = length(aws_instance.web_app)
  port             = 80
}