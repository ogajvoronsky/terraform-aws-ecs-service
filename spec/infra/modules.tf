
module "base_network" {
  source = "git@github.com:tobyclemson/terraform-aws-base-networking.git//src"

  vpc_cidr = "${var.vpc_cidr}"
  region = "${var.region}"
  availability_zones = "${var.availability_zones}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  bastion_ami = "${var.bastion_ami}"
  bastion_ssh_public_key_path = "${var.bastion_ssh_public_key_path}"
  bastion_ssh_allow_cidrs = "${var.bastion_ssh_allow_cidrs}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"
}

module "ecs_cluster" {
  source = "git@github.com:tobyclemson/terraform-aws-ecs-cluster.git//src"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  private_subnet_ids = "${module.base_network.private_subnet_ids}"
  private_network_cidr = "${var.private_network_cidr}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  cluster_name = "${var.cluster_name}"
  cluster_node_ssh_public_key_path = "${var.cluster_node_ssh_public_key_path}"
  cluster_node_instance_type = "${var.cluster_node_instance_type}"

  cluster_minimum_size = "${var.cluster_minimum_size}"
  cluster_maximum_size = "${var.cluster_maximum_size}"
  cluster_desired_capacity = "${var.cluster_desired_capacity}"
}

module "ecs_service" {
  source = "../../src"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  vpc_id = "${module.base_network.vpc_id}"

  region = "${var.region}"

  service_name = "${var.service_name}"
  service_task_definition = "${var.service_task_definition}"
  service_image = "${var.service_image}"
  service_command = "${var.service_command}"
  service_port = "${var.service_port}"

  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"
  ecs_cluster_log_group = "${module.ecs_cluster.log_group}"

  private_subnet_ids = "${module.base_network.private_subnet_ids}"

  ecs_cluster_service_role_arn = "${module.ecs_cluster.service_role_arn}"

  service_certificate_body = "${var.service_certificate_body}"
  service_certificate_private_key = "${var.service_certificate_private_key}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"
}

