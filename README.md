# 🏖 Sandbox swutuf

A minimal demo showing swutuf downloading an update and streaming it to SWUpdate via Unix Domain Socket (UDS) on a QEMU image. Built with isar-cip-core。

- [swutuf]((https://gitlab.com/cip-playground/swutuf)): Lightweight tool using [TUF](https://theupdateframework.io/) metadata to validate and download targets
- [SWUpdate](https://swupdate.org/): Software update framework for embedded Linux
- [isar-cip-core](https://gitlab.com/cip-project/cip-core/isar-cip-core): CIP-based Debian/Isar build environment

## Architecture Overview

~~~plaintext
+--------------+                                            
|     User     |------------------------------------+       
+--------------+    2. Post artifacts infomation    |       
        |                                           |       
1. Post artifacts                                   |       
        |                                           |       
+--------------+                            +--------------+
|  Webserver   |                            |  RSTUF API   |
|  :8080       |←-------------+             |  :8008       |
+--------------+              |             +--------------+
        |                     |                     |       
        |                     ↓                     ↓       
        |             +--------------+      +--------------+
        |             |   Storage    |      |    Broker    |
  Get metadata        +--------------+      +--------------+
  Get artifacts               ↑                     ↑       
        |                     |                     ↓       
        |                     |             +--------------+
        |                     +------------→| RSTUF Worker |
        |              Post/Get metadata    +--------------+
        |                                                   
        |                                                   
+--------------+     /tmp/sockinstctrl      +--------------+
|    swutuf    |---------------------------→|   SWUpdate   |
+--------------+     Send data via UDS      +--------------+
~~~

## Demo Guide

### Setup

First, start the server by running:

~~~sh
just server setup
~~~

Next, build the image. Begin by setting the host IP address:

~~~sh
export HOST_IP="x.x.x.x"
~~~

To build **version 1.0.0**, use:

~~~sh
just image build
~~~

For **version 2.0.0**, specify the build directory and software version:

~~~sh
BUILD_DIR="build2" SW_VERSION="2.0.0" just image build
~~~

Finally, upload the artifacts:

~~~sh
just upload-v2
~~~

***

### Run

Start by running the QEMU image:

~~~sh
just image run
~~~

Check the current software version:

~~~sh
cat /etc/sw-versions
# software="1.0.0"
~~~

Apply the update using `swutuf`. The device will reboot automatically:

~~~sh
swutuf cip-core-qemu-amd64_update.swu
~~~

After the reboot, verify the update and finalize the environment:

~~~sh
bg_printenv -p 1 -o revision,ustate
# Using config partition #1
# Values:
# revision:         3
# ustate:           2 (TESTING)

bg_setenv -c
# Environment update was successful.

bg_printenv -p 1 -o revision,ustate
# Using config partition #1
# Values:
# revision:         3
# ustate:           0 (OK)

cat /etc/sw-versions
# software="2.0.0"
~~~
