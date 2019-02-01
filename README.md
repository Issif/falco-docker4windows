# falco-docker4windows
A docker to run falco in Docker for Windows

# Why?

As Docker for Windows runs inside a VM (HyperV or VirtualBox) with a custom kernel from LinuxKit (https://github.com/linuxkit/linuxkit), falco can't run natively in that environment.

We have to compile an adapted kernel module for LinuxKit and use it.

# How ?

Get version of kernel in use in your VM for Docker for Windows :
```
docker run -ti --rm alpine:latest uname -r | cut -f1 -d"-"

4.9.125
```

Simply run :

```
docker run -i -t --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro issif/falco-docker4windows:{TAG}
```

> Adapt *{TAG}* to use the right version for your kernel (4.9.125 in example above)

> `--privileged` argument is used to permit docker add kernel module with entrypoint

# Dockerfiles

Where are they? They are in their own branch, one by kernel version. If yours is missing, please create an issue or pull request. I will try to keep each branch up to date with sysdig and falco releases. 

# Special thanks

* Michael Ducy (https://github.com/mfdii) for his help with module compilation and advices on slack
* Ethan Sutin (https://github.com/etown) for his work to same idea, it was really inspiring (https://github.com/etown/install-sysdig-module)
