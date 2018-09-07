# qemu-user-static-execmyself-for-docker-automated-build

We can't use binfmt on docker automated-build. This idea may be a solution.

## qemu-execmyself.patch

- When you call `exec("/bin/ls");` in qemu, qemu-execmyself.patch changes it to `exec("/usr/local/bin/qemu-user-static-execmyself /bin/ls")`.
- Then, you can execute a binary which can't run on host architecture from qemu without using binfmt.
- But you can't execute a binary which can't run on /usr/local/bin/qemu-user-static-execmyself including host architecture.

## qemu-support-shebang.patch

- You can now use `qemu-user-static-execmyself ./test.sh` style.

## debootstrap-nomount.patch

- In `debootstrap --second-stage`, debootstrap try to mount /proc and other.
- But if you use a Docker container, you don't have to mount /proc and other.
- debootstrap-nomount.patch removes a mount/unmount command from the file `function`.
