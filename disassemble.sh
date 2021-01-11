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





if [ "$tools" == "available" ] ; then
  
  objdump -b binary -D -m i386:x86-64 Core.i64
  echo
  ${AA64TOOLS}aarch64-none-linux-gnu-objdump -b binary -D -m aarch64 bin/Core.a64
  echo
  ${AA32TOOLS}objdump -b binary -D -m cortex-a9 bin/Core.a32
  echo
  ${RISCVTOOLS}riscv64-unknown-elf-objdump -b binary -D -m riscv:rv64 bin/Core.v64
  echo
  ${RISCVTOOLS}riscv64-unknown-elf-objdump -b binary -D -m riscv:rv32 bin/Core.v32

fi

