module "k8s_wordpress" {
  source = "./modules/k8s_wordpress"

  k8s_cluster_dependency_id = module.my_k8s.k8s_cluster_id
  k8s_cluster_eip_id        = aws_eip.k8s_eip.id
  k8s_configfile_path       = var.k8s_configfile_path

  #pv_efs_ip = "${aws_efs_mount_target.efs_target1.ip_address}"
  db_host     = aws_db_instance.wpdb.address
  db_name     = aws_db_instance.wpdb.name
  db_user     = var.db_user
  db_password = var.db_password

  wordpress_image = var.wordpress_image
  wordpress_name  = "mywordpress"
}

resource "aws_alb_target_group" "wp_targ" {
  port     = module.k8s_wordpress.service_out_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
}

resource "aws_alb_target_group_attachment" "wp_attach_web_servers" {
  target_group_arn = aws_alb_target_group.wp_targ.arn
  target_id        = element(module.my_k8s.k8s_nodes_ids, count.index)
  count            = var.k8s_count
}

resource "aws_alb_listener" "wp_list" {
  default_action {
    target_group_arn = aws_alb_target_group.wp_targ.arn
    type             = "forward"
  }
  load_balancer_arn = aws_alb.alb.arn
  port              = 8080
}

