# 🏖 Sandbox swutuf

A minimal demo showing `swutuf` downloading an update and streaming it to `SWUpdate` via a Unix domain socket (UDS) on a QEMU image. It is built with `isar-cip-core`.

- [swutuf](https://gitlab.com/cip-playground/swutuf): Lightweight tool using [TUF](https://theupdateframework.io/) metadata to validate and download targets
- [SWUpdate](https://swupdate.org/): Software update framework for embedded Linux
- [isar-cip-core](https://gitlab.com/cip-project/cip-core/isar-cip-core): CIP-based Debian/Isar build environment

## Architecture Overview

~~~plaintext
+--------------+                                            
|     User     |------------------------------------+       
+--------------+    2. Post artifacts information   |       
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

### Prerequisites

Make sure the following tools are installed before running the demo:

- Docker Engine
- Docker Compose V2 (`docker compose`)
- QEMU x86 emulator (`qemu-system-x86_64`)

### Setup

After cloning the repository, initialize the `isar-cip-core` submodule:

~~~sh
just init
~~~

First, start the server:

~~~sh
just server setup
~~~

Next, set the host IP address:

~~~sh
export HOST_IP="x.x.x.x"
~~~

Then build **version 1.0.0**:

~~~sh
just image build
~~~

To build **version 2.0.0**, specify the build directory and software version:

~~~sh
BUILD_DIR="build2" SW_VERSION="2.0.0" just image build
~~~

Finally, upload the artifacts:

~~~sh
just upload-v2
~~~

### Run

Start the QEMU image:

~~~sh
just image run
~~~

Check the current software version:

~~~sh
cat /etc/sw-versions
# software="1.0.0"
~~~

Apply the update using `swutuf`. The device reboots automatically:

~~~sh
swutuf cip-core-qemu-amd64_update.swu
~~~

After the reboot, verify the update and finalize it:

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

## References

For more background on the design and motivation behind this demo:

- [Secure Software Update for Embedded Devices with SWUpdate and TUF - Koshiro Onuki, Toshiba Corp - YouTube](https://www.youtube.com/watch?v=8pzURi-oZFY)
- [Device Management and Delta Update for Embedded Devices with SWUpdate and TUF - Koshiro Onuki - YouTube](https://www.youtube.com/watch?v=Hrk5WpA7jBA)
- [swutuf と SWUpdate による TUF ベースの安全なソフトウェア更新 - Qiita](https://qiita.com/llbxg/items/ceeaac3006795bf88bdd)
