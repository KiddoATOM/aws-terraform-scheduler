module "scheduler_test" {
  source = "../"

  buckets = "test-multipart-szu"

  custom_tags = {
    Company = "ACME Inc"
    Project = "Scheduler"
  }
}
