# hak5c2-Terraform
Hak5 C2 deployment with Terraform and Godaddy dns update on AWS. This will leverage the benefits of the cloud, using free services, with state saving. I mean, all your data
will be saved. If, for any reason, you want to change your IP or finished the day and don't want to have C2 available on Internet, you can stop the machine and continue tomorrow
with a fresh instance but with the same data.

## Requisites
You must have an AWS account. If you are new to Terraform you must install this two components:
- https://awscli.amazonaws.com/AWSCLIV2.msi
- https://developer.hashicorp.com/terraform/downloads

Terraform zip has only an executable you must put somewhere in your PATH variable.

Once awscli is installed, you can use the cli command to configure your account using a access and secret key:
```
aws configure
```
You must create a S3 bucket with a directory called backup and this files:
- cloudc2.service: systemd service file. You will find it at files directory.
- hak5c2_binary.zip: zip file with the C2 binary. The name has to be c2-3.2.0_amd64_linux. In case of version upgrade, init.sh must be changed. (Yes, I know, this has to be improved)
- hak5c2_config_latest.zip: zip file with the database, c2.db. You must include the server certificate in case you don't want to use letsencrypt. In this case, you must change the service file to include the cert and key on the command line.
- hak5c2_scripts.zip: file with infrastructure utility scripts. At the moment, there is only backup.sh that you can find at files directory

You must create a role to assign to EC2 instance in order to be able to read and write on the bucket. First, create a IAM Policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": [
                "arn:aws:s3:::<your-bucket>/*"
            ]
        }
    ]
}
```
At the resource section, you must put the name of your bucket.

Now, you are ready to create a IAM role with this policy. Remember the name, you will need it!

Another things you must need are a VPC, Public subnet, ssh keys and security group. There are tons of info around on how to create them.

Needed ports:
- 80
- 8080
- 443
- 2022: needed for ssh tunnel with the devices. Useful if you want to use device shell.
 
Not all this ports are needed if you use your own certificate. LetsEncrypt needs it, so if you follow this guide, open those ports.

Last but not least, open port 22 if you want to ssh into the instance. 

## Configuration
Clone this repository and cd into hak5c2 directory. Edit main.tf template and change:
- key and secret at provider godaddy section. This are your key pair to use Godaddy's API.
- vps_security_group_ids: the IDs of the security group(s) you want to asssign to the instance.
- subnet_id: ID of the public subnet where you want to launch the instance
- key_name: name of the ssh key pair you have configured at AWS. You must have the key to ssh into the instance.
- iam_instance_profile: name of the created role. Check requisites section if you don't know what i am talking about.
- domain: name of your domain. E.G.: example.com
- name: name of the subdomain you want to create under domain. E.G.: hak5c2

Not need to change. For reference:
- ami: the OS image. Is an Ubuntu Server 22.04. Not need to change for now.
- instance_type: you must choose whatever you want to pay but a t2.micro is fine. Remember, Free tier. 
- tags: whatever you like
- ttl: the minimum is 600 seconds. If you need to recreate the instance several times, a lower TTL will do the entire process faster.
- data: not need to be changed but, if you changed the name of the instance, then you must set change this in order to create the dns with the correct IP address.
 
Edit init.sh script and change:
- bucket: the name of your bucket
- dns: put here the desired fqdn you want to assign the instance. This will be your url to access the C2 website.
- binary, config, scripts and service: there are only names. Not need to change but if you do, change the name of the files at the bucket to match those.

Edit files/backup.sh to match your bucket name. 

## Execution
The first time you must initialize Terraform environment. This will download the needed packages.
```
terraform init
```

When you changes something on the main.tf file you must ensure everything is correct by doing:
```
terraform fmt
terraform validate
```

Create instance and DNS:
```
terraform apply
```

It lasts about 70 seconds to configure itself, be patient!. You must review /var/log/cloud-init-output.log to see the process. It must end with:
```bash
dos2unix: converting file /opt/hak5c2/scripts/backup.sh to Unix format...
Cloud-init v. 23.1.2-0ubuntu0~22.04.1 finished at Tue, 13 Jun 2023 17:33:50 +0000. Datasource DataSourceEc2Local.  Up 73.07 seconds
```
Mmmmm, George, how do I view the log if you didn't teach me to enter the instance? 
```bash 
ssh -i /home/george/hak5c2.pem ubuntu@subdomain.example.com
```
Note: if you recreate the instance in the last minutes, you must be in the TTL window so you must prefer use the IP instead of the domain name :)

## Destroy!
If you want to terminate the instance, this is your place. I don't know why but dns won't clear but whatever.. 
```
terraform destroy
```

## How to save my data?
You can use the backup.sh script at /opt/hak5c2/scripts but you are backuping data when the application is running. The service unit will execute it
when you stop the service. But.... This will occur when executing terraform destroy so you won't have to worry about it. 

# Improvements
- Create Policy/Role, ssh key, etc.
- Create instance in private subnet and connect to a reverse proxy using ssh tunnel.
- Create backup.sh file from init.sh using the variables.
- Use a non version binary for mental healthness.
