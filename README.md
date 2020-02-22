# aws-terraform-scheduler-monitor

This module sets up a start scheduler lambda function and a stop scheduler lambda function. The start scheduler lambda starts the instance that has the set tag name and tag value in the variables. The stop scheduler lambda stops the instance that has the set tag name and tag key in the variables. The stop function also cleans the ECR repositories whose names are configured in the repositories variable and S3 buckets whose names are configured in the buckets variable. 

## Usage

```HCL
module "scheduler_test" {
  source = "../"

  custom_tags = {
    Company = "ACME Inc"
    Project = "Scheduler"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| custom\_tags | Optional tags to be applied on top of the base tags on all resources | `map(string)` | `{}` | no |
| environment | Environment for wich this module will be created. E.g. Development | `string` | `"Development"` | no |
| log\_retention | Specifies the number of days you want to retain log events in the specified log group. | `number` | `14` | no |
| repositories | List of repositories to clean up by lambda scheduler. Comma separated names of the repositories to clean. | `string` | `""` | no |
| buckets | List of buckets to clean up by lambda scheduler. Comma separated names of the buckets to clean. | `string` | `""` | no |
| scheduler\_tag\_name | Tag name to use as filter for lambda scheduler. | `string` | `"Scheduler"` | no |
| scheduler\_tag\_value | Tag value to use as filter for lambda scheduler. | `string` | `"true"` | no |
| start\_time | Schedule expression when instance will be started. | `string` | `"cron(0 8 ? * MON-FRI *)"` | no |
| stop\_time | Schedule expression when instance will be stoped and repositores clean | `string` | `"cron(0 19 ? * MON-FRI *)"` | no |

## Outputs

No output.
