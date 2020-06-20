#!/usr/bin/python

import boto3
import botocore
import sys


def main():
    topic_arn = sys.argv[1]
    access_key = sys.argv[2]
    secret_key = sys.argv[3]
    symphony_ip = sys.argv[4]

    print ("Disabling warning for Insecure connection")
    botocore.vendored.requests.packages.urllib3.disable_warnings(
        botocore.vendored.requests.packages.urllib3.exceptions.InsecureRequestWarning)

    print ("Creating SNS client")
    sns_client = boto3.client(service_name="sns", region_name="symphony",
                              endpoint_url="https://%s/api/v2/aws/sns/" % symphony_ip,
                              verify=False,
                              aws_access_key_id = access_key,
                              aws_secret_access_key=secret_key)

    print("Subscribing Topic %s" % topic_arn)
    sns_client.subscribe(TopicArn=topic_arn, Protocol="email", Endpoint="liaz@stratoscale.com")


if __name__ == "__main__":
    main()


