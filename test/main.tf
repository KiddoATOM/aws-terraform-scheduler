module "scheduler_test" {
  source = "../"

  custom_tags = {
    Company = "ACME Inc"
    Project = "Scheduler"
  }
}
