# MCBackup
An efficient backup system to backup files on Linux Systems focused on Minecraft Networks *(This is my first Bash script ;-; plz be nice)* It uses the Amazon S3 cloud storage system, which is a pretty good choice for when backing up files!

Contact me: Intriguing#0001

## Supported Distributions
✅ = Tested <img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> = Not Tested ❌ = Not Supported

<img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> Ubuntu 20.04 LTS<br>
✅ Ubuntu 18.04 LTS<br>
<img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> Ubuntu 16.04 LTS<br>
<img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> Debian 10<br>
<img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> Debian 9<br>
<img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> CentOS 8<br>
<img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> CentOS 7


## Required Dependencies
### **yq by mikefarah**<br>
Usage: Uses yq to read the YAML configuration file<br><br>
Installation:<br>
**1)** Visit https://github.com/mikefarah/yq/releases/latest and download the latest binary release for your system.<br>
Find more information about your distrubtion with the `hostnamectl` command!
```
yq_linux_amd64 = 64 Bit Linux Systems
```
**2)** Rename the file to `yq` and move the file to the `/usr/bin/` folder

### **mysql** (Optional: Only install if your server uses MySQL databases and you want to backup them)<br>
**Usage:** Used for creating a MySQLDump (Backing up your databases)<br>
**Installation:**<br>
Search https://google.com: "How to install MySQL on (YOUR DISTRIBUTION)"

### **curl**
**Usage:** To install AWS CLI<br>
**Installation:**<br>
Search https://google.com: "How to install curl on (YOUR DISTRIBUTION)"

### **zip/unzip**
**Usage:** To install AWS CLI<br>
**Installation:**<br>
Search https://google.com: "How to install zip and unzip on (YOUR DISTRIBUTION)"

### **aws cli** <br>
**Usage:** Upload files to AWS S3 service<br>
**Installation:**<br>
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## Setup

### An AWS S3 service
Most people go to Amazon S3 for their AWS S3 service, however, there are __CHEAPER__ options which serve similar functionailities. One of my favorites is https://wasabi.com. Why? It's **CHEAPER** ($5.99 / TB with a 1 month free trial, no hidden fees), **SECURE**, **FAST**, and **EASY TO USE**. Any AWS S3 service is alright as long as you have an:
* Endpoint URL
* Secret Key
* Access Key
* Region

I will go over on how to setup Wasabi in this tutorial.

**#1)** Visit https://wasabi.com and sign up for an account and confirm your email, and create a password!<br>
<img height=300 src="https://i.imgur.com/S6It8Oo.png"><br><br>

**#2)** Once you're in the Wasabi Console, go to the "Users" tab and click "Create User"<br>
<img height=300 src="https://i.imgur.com/BrCNYwc.png"><br><br>

**#3** A menu will open up. Apply the following options:<br>
  1) Set the username to anything that you want, this won't matter<br>
  2) For type of access, be sure you click Programmatic (create API key), and not Console, this will allow the user to only to connect via the S3 API and not through console.<br>
  3) Visit next page -> You don't need to set any groups -> Visit next page<br>
  4) Assign the WasabiWriteOnlyAccess to the user, this will allow the user to ONLY write to Wasabi, they won't be able to delete, etc.<br>
  5) Visit next page -> Click Create User<br>
<img height=300 src="https://i.imgur.com/idx3tdV.png"><br><br>

**#4** When you close the create user menu, it will show a secret and access key. Copy these keys for the configuration part of this setup! If you accidently closed that menu, fear not, you can regenerate the access key by:<br>
  1) Clicking on the user you made in the Users tab<br>
  2) Clicking on "User Access Keys"<br>
  3) Delete the current access key and create a new key<br>
  4) Click on show Secret Key and copy the keys! Be sure to not lose the key until we get to the configuration process.<br>
<img height=300 src="https://i.imgur.com/u96pHfG.png"><br>
<img height=300 src="https://i.imgur.com/jRbU7zh.png"><br><br>

**#5** Make the bucket and directories! Go back to the "Buckets" tab and click "Create Bucket"! Following the following steps:<br>
  1) Input a bucket name (it can be anything as long as it's not taken within the Wasabi database)<br>
  2) Select a region (Pick the closest one to your server!)<br>
  3) Click Create Bucket<br><br>
  
  Within the bucket create the folders of the servers you want to back up!<br>
  Here's an example file tree:<br><br>
  ```
  MyNetworkBackups (bucket)/
  ├── hub
  ├── proxy
  └── skyblock
  ```
  Once that's complete, each server needs the following folders for **non compressed backups**, **compressed backups**, and **sql backups**. The final folder structure should look something like this:
  ```
  MyNetworkBackups (bucket)/
  ├── hub
  │   ├── compressed
  │   ├── non_compressed
  │   └── sql
  ├── proxy
  │   ├── compressed
  │   ├── non_compressed
  │   └── sql
  └── skyblock
      ├── compressed
      ├── non_compressed
      └── sql
   ```
   
   *(( Note: You don't need to put the folders you don't want! For example, if you don't want Non Compressed backups, don't put a Non Compressed folder! ))*
  
## Downloading the script
Download the script and config here: [CLICK ME!](https://github.com/Intriguing-RC/MCBackup/releases)
Feel free to put them in any folder (maybe the root or home directory), **BUT** make sure they are both in the **SAME FOLDER**!

To run the script, simply do:
```
chmod a+x backup
./backup```

## Configuration Guide
[Click here](https://github.com/Intriguing-RC/MCBackup/wiki)
