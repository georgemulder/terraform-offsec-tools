#!/bin/bash
bucket="mybucket"
sudo /usr/bin/aws s3 mv s3://$bucket/hak5c2_config_latest.zip s3://$bucket/backup/hak5c2_config_$(date '+%d%m%y_%H%M').zip
sudo zip -rj /opt/hak5c2_config_latest.zip /opt/hak5c2/cloudc2/
sudo /usr/bin/aws s3api put-object --bucket $bucket --key hak5c2_config_latest.zip --body /opt/hak5c2_config_latest.zip
