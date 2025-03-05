#!/bin/bash

## Phone pool and phone number
POOL_ID=$(aws pinpoint-sms-voice-v2  describe-pools --query 'Pools[0].PoolId' --output text)

aws pinpoint-sms-voice-v2 describe-pools \
    --pool-ids $POOL_ID \
    --query 'Pools[0]'

aws pinpoint-sms-voice-v2 request-phone-number \
    --iso-country-code US \
    --message-type TRANSACTIONAL \
    --number-capabilities SMS \
    --number-type SIMULATOR \
    --pool-id $POOL_ID

## Opt(optional)-out list

### created by terraform

aws pinpoint-sms-voice-v2 describe-opted-out-numbers \
    --opt-out-list-name product_survey

## configuration set

### created by terraform

### create protect configuration and associated to configuration set manually

## event destination
LOG_GROUP_ARN=$(aws logs describe-log-groups \
    --log-group-name-pattern '*sms-messaging' \
    --query 'logGroups[0].arn' --output text | head -n 1) && echo $LOG_GROUP_ARN

### Create custom IAM resources

#### IAM role created by terraform

#### IAM policy created by terraform

ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
AWS_REGION=ap-northeast-1

aws iam list-attached-role-policies \
    --role-name qapp-dev-SMS-cloudwatch-role

aws pinpoint-sms-voice-v2 create-event-destination \
    --configuration-set-name qapp-dev-configset \
    --event-destination-name "SMSCloudWatch" \
    --matching-event-types TEXT_ALL \
    --cloud-watch-logs-destination IamRoleArn="arn:aws:iam::038462772752:role/qapp-dev-SMS-cloudwatch-role",LogGroupArn="${LOG_GROUP_ARN}"

# {
#     "ConfigurationSetArn": "arn:aws:sms-voice:ap-northeast-1:038462772752:configuration-set/qapp-dev-configset",
#     "ConfigurationSetName": "qapp-dev-configset",
#     "EventDestination": {
#         "EventDestinationName": "SMSCloudWatch",
#         "Enabled": true,
#         "MatchingEventTypes": [
#             "TEXT_ALL"
#         ],
#         "CloudWatchLogsDestination": {
#             "IamRoleArn": "arn:aws:iam::038462772752:role/qapp-dev-SMS-cloudwatch-role",
#             "LogGroupArn": "arn:aws:logs:ap-northeast-1:038462772752:log-group:/qapp/dev/sms-messaging:*"
#         }
#     }
# }
