#!/bin/bash -f

FILE=$(basename ${1} .elf)

arm-none-eabi-objcopy --gap-fill 0xff -O binary ${1} ${FILE}.bin
hexdump -v -e '1/4 "%08X\n"' ${FILE}.bin > ${FILE}.hex
rm -rf ${FILE}.bin
