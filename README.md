# HDLC Controller Verification using SystemVerilog Assertions (SVA)

This repository contains my coursework verification work for an HDLC (High-level Data Link Control) controller, focusing on **assertion-based verification** (immediate + concurrent assertions) and functional checks of RX/TX behavior.
## What I verified (high level)
### Part A (RX-focused)
- **Immediate assertions** in the test program for:
  - Normal receive: expected **Rx SC** status bits and RX buffer contents (data readback)
  - Abort receive: RX buffer empty/zeros and **Rx AbortSignal** behavior :contentReference
  - Overflow receive: **Rx Overflow** and first 126 bytes retained in RX buffer
- **Concurrent assertions (SVA)** for:
  - HDLC **flag sequence** detection (01111110)
  - Abort during valid frame → **Rx AbortSignal**

### Part B (extended checks)
Expanded verification scope to cover additional requirements such as TX output behavior, start/end flags, idle/abort patterns, zero insertion/removal, CRC checking, frame sizing, ready/done/full signaling, etc.

## Repo layout
- `tb/assertions_hdlc.sv` — concurrent assertions (SVA properties)
- `tb/testPr_hdlc.sv` — test program tasks + immediate assertions (normal/abort/overflow, etc.) 
- `docs/` — project reports (Part A/Part B)

## Tools / environment
- SystemVerilog + SVA
- Questa/ModelSim flow using provided scripts (`compile.sh`, `simulate.sh`) (course setup)
