# ibex: RISC-V Core

**ibex** is a small 2-stage RISC-V core derived from RI5CY.

**ibex** fully implements the RV32IMC instruction set and a minimal
set of RISCV privileged specifications.
**ibex** can be configured to be very small by disabling the RV32M extensions
and by activating the RV32E extensions. This configuration is called **micro-riscy**

The core was developed as part of the [PULP platform](http://pulp.ethz.ch/) for
energy-efficient computing and is currently used as the control core for
PULP and PULPino.

## Documentation

A datasheet that explains the most important features of the core can be found
in the doc folder.

