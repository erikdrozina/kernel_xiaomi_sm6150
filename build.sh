#! /bin/bash

# clone or update Azure Clang if it alreay exists
set -e

echo -e "Start building Phobos Kernel\n"

if [ -r clang ]; then
    echo "* Azure Clang found! * "
    cd clang
    git config pull.rebase false
    cd ..
else
    echo "* Azure Clang not found, cloning it now * "
    git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang clang
fi

KERNEL_DEFCONFIG=tucana_defconfig
KERNELDIR=$PWD/
export PATH="${PWD}/clang/bin:${PATH}"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_COMPILER_STRING="$(${PWD}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
# speed up build process
MAKE="./makeparallel"

# cleanup
echo -e "\n* Cleaning *\n"
if [ -r out ]; then
    rm -rf out
fi
mkdir -p out

# build kernel
echo "* Kernel defconfig is set to $KERNEL_DEFCONFIG *"
echo -e "* Building kernel *\n"
make $KERNEL_DEFCONFIG O=out
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      LD=ld.lld

echo
echo "    ____  __          __                  __ __                     __"
echo "   / __ \/ /_  ____  / /_  ____  _____   / // /__  _________  ___  / /"
echo "  / /_/ / __ \/ __ \/ __ \/ __ \/ ___/  /   </ _ \/ ___/ __ \/ _ \/ / "
echo " / ____/ / / / /_/ / /_/ / /_/ (__  )  / /| /  __/ /  / / / /  __/ /  "
echo "/_/   /_/ /_/\____/_____/\____/____/  /_/ |_\___/_/  /_/ /_/\___/_/   "
echo
