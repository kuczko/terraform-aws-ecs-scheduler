# terraform-aws-ecs-scheduler
This module provides a way to stop ecs services for scheduled time and restore them afterwards.
Example usage:

```
module "ecs-scheduler" {
  source       = "https://github.com/kuczko/terraform-aws-ecs-scheduler.git?ref=0.1.0"
  namespace    = var.project_name
  stage        = local.stage
  cluster_name = "my_cluster_name"
  region       = var.region
  cron_start   = "cron(00 06 ? * MON-FRI *)"
  cron_stop    = "cron(00 18 ? * MON-FRI *)"

  ecs_services = [
    {
      service_name  = "service1"
      desired_count = "1"
    },
    {
      service_name  = "service2"
      desired_count = "4"
    }
  ]
}
```
