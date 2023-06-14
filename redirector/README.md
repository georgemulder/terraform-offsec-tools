# hak5c2-Terraform
Apache Reverse Proxy for C2 deployments with Terraform on AWS. This is your repo if you want to hide your TeamServers or whatever tool you use from the Internet.

## Requisites
You must have an AWS account. If you are new to Terraform you must install this two components:
- https://awscli.amazonaws.com/AWSCLIV2.msi
- https://developer.hashicorp.com/terraform/downloads

Terraform zip has only an executable you must put somewhere in your PATH variable.

Once awscli is installed, you can use the cli command to configure your account using a access and secret key:
```
aws configure
```
Another things you must need are a VPC, Public subnet, ssh keys and security group. There are tons of info around on how to create them.

Needed ports:
- 443

Last but not least, open port 22 if you want to ssh into the instance. 

## Configuration
Clone this repository and cd into redirector directory. Edit main.tf template and change:
- vps_security_group_ids: the IDs of the security group(s) you want to asssign to the instance.
- subnet_id: ID of the public subnet where you want to launch the instance
- key_name: name of the ssh key pair you have configured at AWS. You must have the key to ssh into the instance.

Not need to change. For reference:
- ami: the OS image. Is an Ubuntu Server 22.04. Not need to change for now.
- instance_type: you must choose whatever you want to pay but a t2.micro is fine. Remember, Free tier. 
- tags: whatever you like
- region: where you want to deploy. Default: Ireland (eu-west-1)

If you want to change the default redirects, open init.sh script and change:
```bash
sudo echo -e 'RewriteEngine on\nRewriteCond %{REQUEST_URI} cooking [NC]\nRewriteRule .* https://localhost:8443%{REQUEST_URI} [P]\nRewriteCond %{REQUEST_URI} chaos [NC]\nRewriteRule .* https://localhost:8444%{REQUEST_URI} [P]\nRewriteCond %{REQUEST_URI} witch [NC]\nRewriteRule .* https://localhost:8445%{REQUEST_URI} [P]\nRewriteRule .* https://localhost:8446%{REQUEST_URI} [P]' > /tmp/temp
```
For readability. The prettified htaccess file:
```bash
RewriteEngine on
RewriteCond %{REQUEST_URI} cooking [NC]
RewriteRule .* https://localhost:8443%{REQUEST_URI} [P]
RewriteCond %{REQUEST_URI} chaos [NC]
RewriteRule .* https://localhost:8444%{REQUEST_URI} [P]
RewriteCond %{REQUEST_URI} witch [NC]
RewriteRule .* https://localhost:8445%{REQUEST_URI} [P]
RewriteRule .* https://localhost:8446%{REQUEST_URI} [P]'
```
Being, for instance:
|C2|Port|URL Resource|
|---|---|---|
|Sliver|8443|cooking| 
|Havoc|8444|chaos|
|Covenant|8445|witch|
|Sharpc2|8446|/|

So, if you want to access Sliver you must point to https://<yourdomain>/cooking. Apache will redirect to itself at port 8443.

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

Create instance:
```
terraform apply
```

It lasts about 50 seconds to configure itself, be patient!. You can review /var/log/cloud-init-output.log to see the process. It must end with:
```bash
Hello from Web Server
Cloud-init v. 23.1.2-0ubuntu0~22.04.1 finished at Sat, 10 Jun 2023 10:20:45 +0000. Datasource DataSourceEc2Local.  Up 49.92 seconds
```
Mmmmm, George, how do I view the log if you didn't teach me to enter the instance? 
```bash 
ssh -i /home/george/redirector.pem ubuntu@ip
```

## Teamservers configuration
In order to use this Reverse Proxy you must create a SSH tunnel from your teamserver to the Apache instance.

Copy the ssh key to your Teamserver:
```bash
scp redirector.pem user@sliver:.ssh/
```

```bash
chmod 600 /home/user/.ssh/redirector.pem
ssh-keyscan -H <ip> >> /home/user/.ssh/known_hosts
```

Following the previous example. Execute this on each Teamserver:
- Sliver
   ```bash
   echo -e 'Host\tredirector-1\nHostName\t2.150.119.23\nUser\tubuntu\nPort\t22\nIdentityFile\t/home/user/.ssh/redirector.pem\nRemoteForward\t8443 localhost:443\nServerAliveInterval  30\nServerAliveCountMax  3' >> /home/user/.ssh/config
   ```
- Havoc
   ```bash
   	echo -e 'Host\tredirector-1\nHostName\t2.150.119.23\nUser\tubuntu\nPort\t22\nIdentityFile\t/home/user/.ssh/redirector.pem\nRemoteForward\t8444 localhost:443\nServerAliveInterval  30\nServerAliveCountMax  3' >> /home/user/.ssh/config
   ```
- Covenant
   ```bash
   echo -e 'Host\tredirector-1\nHostName\t2.150.119.23\nUser\tubuntu\nPort\t22\nIdentityFile\t/home/user/.ssh/redirector.pem\nRemoteForward\t8445 localhost:443\nServerAliveInterval  30\nServerAliveCountMax  3' >> /home/user/.ssh/config
   ```
- SharpC2
   ```bash
   	echo -e 'Host\tredirector-1\nHostName\t2.150.119.23\nUser\tubuntu\nPort\t22\nIdentityFile\t/home/user/.ssh/redirector.pem\nRemoteForward\t8446 localhost:443\nServerAliveInterval  30\nServerAliveCountMax  3' >> /home/user/.ssh/config
   ```
Don't forget to change the IP to match the instance one. Change the key and config directory too.

Connect to the proxy:
```bash
autossh -M 0 -f -N redirector-1
```

That's all.
# Improvements
- Configure DNS with Terraform and change every IP to DNS on the echo commands.
