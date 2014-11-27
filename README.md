docker-rundeck
==============

Creates a rundeck docker environment

Using the image as-is
---------------------
The instance listens on http://127.0.0.1:4440/
The default password is admin:CH4NGE_Me
You can ssh to your instance. The root user has the same password as above.

Build your own Docker image
---------------------------

Installation
------------
* Modify RDPASS variable in Dockerfile
* Change MYHOST variable to your host/ip address
* Generate and add your SSH key pair to .ssh/. The id_rsa.pub key in .ssh/ will be used to log on to remote servers

Then build your docker image with `docker build --rm=true --tag=rundeck`

The image includes an ssh daemon so you can ssh to your docker instance as root and log in with your RDPASS password.
