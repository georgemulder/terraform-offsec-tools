#!/bin/bash
bucket="mybucket"
binary="hak5c2_binary.zip"
config="hak5c2_config_latest.zip"
scripts="hak5c2_scripts.zip"
service="cloudc2.service"
dns="desiredsubdomain.example.com"
# Don't change destination variable. It will break everything.
destination="/opt"

sudo apt-get update -y; sudo apt-get install awscli unzip zip dos2unix -y
sudo /usr/bin/aws s3api get-object --bucket $bucket --key $binary $destination/$binary
sudo unzip $destination/$binary -d $destination/hak5c2
sudo /usr/bin/aws s3api get-object --bucket $bucket --key $config $destination/$config
sudo unzip $destination/$config -d $destination/hak5c2/cloudc2
sudo /usr/bin/aws s3api get-object --bucket $bucket --key $scripts $destination/$scripts
sudo unzip $destination/$scripts -d $destination/hak5c2/scripts
sudo /usr/bin/aws s3api get-object --bucket $bucket --key $service /usr/lib/systemd/system/$service
sudo sed -i "s/HOSTNAME/$dns/" /usr/lib/systemd/system/$service
sudo rm -f $destination/$binary $destination/$config $destination/$scripts
sudo chmod 700 $destination/hak5c2 $destination/hak5c2/cloudc2 $destination/hak5c2/scripts
sudo chmod 700 $destination/hak5c2/c2-3.2.0_amd64_linux $destination/hak5c2/scripts/backup.sh
sudo chmod 600 $destination/hak5c2/cloudc2/c2.db 
sudo mv $destination/hak5c2/c2-3.2.0_amd64_linux $destination/hak5c2/c2_community-linux-64
sudo /usr/bin/dos2unix $destination/hak5c2/scripts/backup.sh
sudo systemctl daemon-reload
sudo systemctl start $service
