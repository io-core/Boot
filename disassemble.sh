AA64TOOLS=/home/arm/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/
AA32TOOLS=/home/arm/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi/bin/
RISCVTOOLS=/home/riscv/bin/

tools="available"

if [ ! -f ${AA64TOOLS}aarch64-none-linux-gnu-as ] ; then
	echo "gnu assembler for aa64 is required and AA64TOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${AA32TOOLS}as ] ; then
	echo "gnu assembler for arm is required and AA32TOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${RISCVTOOLS}riscv64-unknown-elf-as ] ; then
	echo "gnu assembler for riscv is required and RISCVTOOLS must be set correctly"
	tools="unavailable"
fi

what=$1

if [ "$what" == "" ]; then
	what="all"
fi


if [ "$tools" == "available" ] ; then

  if [ "$what" == "rsc" ] || [ "$what" == "all" ] ; then
    echo 
    echo "bin/Core.rsc:     file format binary"
    echo
    echo 
    echo "Disassembly of section .data:"
    echo
    echo "00000000 <.data>:"
    cat bin/Core.rsc.qemu | bash bin/5dis.sh
    echo
  fi

  if [ "$what" == "x8664-qemu" ] || [ "$what" == "all" ] ; then
    objdump -b binary -D -M intel -m i386:x86-64 bin/Core.x8664.qemu
    echo
  fi

  if [ "$what" == "x8664-lin" ] || [ "$what" == "all" ] ; then
    objdump -b binary -D -M intel -m i386:x86-64 bin/Core.x8664.lin
    echo
  fi

  if [ "$what" == "arm64-qemu" ] || [ "$what" == "all" ] ; then
    ${AA64TOOLS}aarch64-none-linux-gnu-objdump -b binary -D -m aarch64 bin/Core.arm64.qemu
    echo
  fi

  if [ "$what" == "arm64-pbpro" ] || [ "$what" == "all" ] ; then
    ${AA64TOOLS}aarch64-none-linux-gnu-objdump -b binary -D -m aarch64 bin/Core.arm64.pbpro
    echo
  fi

  if [ "$what" == "arm64-pphone" ] || [ "$what" == "all" ] ; then
    ${AA64TOOLS}aarch64-none-linux-gnu-objdump -b binary -D -m aarch64 bin/Core.arm64.pphone
    echo
  fi

  if [ "$what" == "arm32-qemu" ] || [ "$what" == "all" ] ; then
    ${AA32TOOLS}objdump -b binary -D -m cortex-a9 -Mreg-names-raw bin/Core.arm32.qemu
    echo
  fi

  if [ "$what" == "cortex4-qemu" ] || [ "$what" == "all" ] ; then
    ${AA32TOOLS}objdump -b binary -D -m cortex-m4 -Mforce-thumb -Mreg-names-raw bin/Core.cortex4.qemu
    echo
  fi

  if [ "$what" == "cortex0-qemu" ] || [ "$what" == "all" ] ; then
    ${AA32TOOLS}objdump -b binary -D -m cortex-m0 -Mforce-thumb -Mreg-names-raw bin/Core.cortex0.qemu
    echo
  fi

  if [ "$what" == "cortex4-ptime" ] || [ "$what" == "all" ] ; then
    ${AA32TOOLS}objdump -b binary -D -m cortex-m4 -Mforce-thumb -Mreg-names-raw bin/Core.cortex4.ptime
    echo
  fi

  if [ "$what" == "cortex0-pico" ] || [ "$what" == "all" ] ; then
    ${AA32TOOLS}objdump -b binary -D -m cortex-m0 -Mforce-thumb -Mreg-names-raw bin/Core.cortex0.pico
    echo
  fi

  if [ "$what" == "riscv64-qemu" ] || [ "$what" == "all" ] ; then
    ${RISCVTOOLS}riscv64-unknown-elf-objdump -b binary -D -m riscv:rv64 -Mnumeric,no-aliases bin/Core.riscv64.qemu
    echo
  fi

  if [ "$what" == "riscv32-qemu" ] || [ "$what" == "all" ] ; then
    ${RISCVTOOLS}riscv64-unknown-elf-objdump -b binary -D -m riscv:rv32 -Mnumeric,no-aliases bin/Core.riscv32.qemu
  fi
  

fi

