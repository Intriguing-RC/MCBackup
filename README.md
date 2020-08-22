# MCBackup
An efficient backup system to backup files on Linux Systems focused on Minecraft Networks. It uses the Amazon S3 cloud storage system, which is a pretty good choice for when backing up files!

Contact me: Intriguing#0001

### Supported Distributions
✅ = Tested <img width=16 height=16 src="https://i.imgur.com/oYtywhM.png"> = Not Tested ❌ = Not Supported

✅ Ubuntu 20.04 LTS<br>
✅ Ubuntu 18.04 LTS<br>
✅ Ubuntu 16.04 LTS<br>
✅ Debian 10 (Extra Dependency Needed - Check Wiki) <br>
✅ Debian 9 (Extra Dependency Needed - Check Wiki) <br>
✅ CentOS 8<br>
✅ CentOS 7<br>
❌ Windows<br>
❌ MacOS

### Required Dependencies
* [`yq by mikefarah (Used for YML configuration files)`](https://github.com/mikefarah/yq)
* [`AWS CLI (Used for uploading files to AWS service)`](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
* MySQL (if your server uses mysql you want to backup)

Debian Only:
* `sudo apt-get install uuid-runtime` - Installs the application needed for generating a temp folder needed for compressing the server and SQL

