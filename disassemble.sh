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

  if [ "$what" == "i64-qemu" ] || [ "$what" == "all" ] ; then
    objdump -b binary -D -M intel -m i386:x86-64 bin/Core.i64.qemu
    echo
  fi

  if [ "$what" == "i64-lin" ] || [ "$what" == "all" ] ; then
    objdump -b binary -D -M intel -m i386:x86-64 bin/Core.i64.lin
    echo
  fi

  if [ "$what" == "a64-qemu" ] || [ "$what" == "all" ] ; then
    ${AA64TOOLS}aarch64-none-linux-gnu-objdump -b binary -D -m aarch64 bin/Core.a64.qemu
    echo
  fi

  if [ "$what" == "a32-qemu" ] || [ "$what" == "all" ] ; then
    ${AA32TOOLS}objdump -b binary -D -m cortex-a9 -Mreg-names-raw bin/Core.a32.qemu
    echo
  fi

  if [ "$what" == "v64-qemu" ] || [ "$what" == "all" ] ; then
    ${RISCVTOOLS}riscv64-unknown-elf-objdump -b binary -D -m riscv:rv64 -Mnumeric,no-aliases bin/Core.v64.qemu
    echo
  fi

  if [ "$what" == "v32-qemu" ] || [ "$what" == "all" ] ; then
    ${RISCVTOOLS}riscv64-unknown-elf-objdump -b binary -D -m riscv:rv32 -Mnumeric,no-aliases bin/Core.v32.qemu
  fi
  

fi

