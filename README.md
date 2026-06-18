# 🗄️ Parameterized Dual-Read Single-Write Register File IP Core

A highly optimized, parameterized **Register File (RegFile)** IP core implemented in synthesizable **Verilog (IEEE 1364-2005)**. This module serves as a high-performance architectural block designed specifically for RISC processor execution pipelines (e.g., RISC-V, MIPS). It features **two independent combinational read ports** and **one synchronous write port**, managing concurrent pipeline operands without structural data hazards.

---

## 📂 Repository Architecture & Directory Structure

The repository workspace follows an industry-standard Electronic Design Automation (EDA) layout, organizing core hardware descriptions, verification testbenches, and automated documentation templates into structured subdirectories:

```text
REGISTER_FILE/
├── .gitignore                  # Excludes compiler artifacts (*.vvp, *.vcd)
├── README.md                   # Core repository overview & architectural manual
├── register_file.md            # Detailed technical specification sheet
├── register_file.svg           # Structural RTL block diagram configuration
├── register_file.v             # Master design: Parameterized Dual-Read Single-Write RegFile
├── testbench.v                 # Testbench driving randomized & regression vectors
├── testbench.vcd               # Value Change Dump waveform trace simulation file
├── testbench.vvp               # Compiled Icarus Verilog simulation runtime binary
└── waveform.png                # Static visualization capture of simulation traces
```

## 🏗️ Architectural Overview & Silicon Design Realities

In a modern processing core, the register file handles heavy traffic loads at high operating frequencies. This module implements several hardware paradigms to maximize throughput and match physical silicon behaviors:

```text
               Synchronous Write Path (Active-High wr)
                            │
                            ▼
                     ┌──────────────┐
     addr_w ────────>│              │
     data_w ────────>│ Write Decode │
                     └──────┬───────┘
                            │ (Clocked @ posedge clk)
                            ▼
              ┌──────────────────────────┐
              │  Register Bank Storage   │
              │  R[0]: Constant Zero     │ <─── Reset (rst_n) clears array
              │  R[1] to R[2^ADDR-1]     │
              └──────────┬────┬──────────┘
                         │    │
         ┌───────────────┘    └────────────────┐
         ▼                                     ▼
  ┌──────────────┐                      ┌──────────────┐
  │ Read Mux R1  │                      │ Read Mux R2  │
  └──────┬───────┘                      └──────┬───────┘
         ▲                                     ▲
         │ (Bypass Check: addr_r1 == addr_w)   │ (Bypass Check: addr_r2 == addr_w)
         │                                     │
  addr_r1 ────────────────────────────── addr_r2
         │                                     │
         ▼                                     ▼
      data_r1                               data_r2
  (Combinational)                       (Combinational)
```

### 🏗️ Key Architectural Features & Hardware Realities

#### 1. Hardwired Zero Register (`R0` Safeguard)

Following standard RISC computer architectures, register index `0` (`addr_w == 0`) is structurally locked. The write-enable control path employs an address reduction OR check (`wr & |addr_w`). This ensures that even if a pipeline instruction attempts a destructive write back to address zero, the internal storage elements safely isolate `R[0]` to serve as a constant, hardwired logic ground (`0`).

#### 2. Read-Before-Write Hazard Mitigation (Write-Forwarding Bypass)

Because the read ports are combinational (`always @(*)`) and the write port is clocked sequentially (`always @(posedge clk)`), a structural data hazard occurs when an instruction attempts to read a register index that is being written to simultaneously during the same execution window. 

To resolve this, the core integrates a **structural bypass network**:

```verilog
else if (addr_r1 == addr_w) 
    data_r1 = data_w;
```

## 🛠️ Toolchain & EDA Tools

This project was developed, simulated, and documented using the following industrial and open-source hardware engineering tool suite:

* **Design & IDE:** [VS Code](https://code.visualstudio.com/) — Integrated development environment used for writing synthesizable RTL code.
* **Documentation Engine:** [TerosHDL](https://teroshdl.github.io/teroSHDL/) — Used for real-time code parsing, block diagram schematic generation, and automated markdown documentation formatting.
* **Simulation & Synthesis Compiler:** [Icarus Verilog (iVerilog)](http://iverilog.icarus.com/) — Open-source Verilog simulation and synthesis tool used to compile the RTL design and testbench.
* **Waveform Viewer:** [GTKWave](https://gtkwave.sourceforge.net/) — Fully featured wave viewer used to open and analyze the compiled `.vcd` (Value Change Dump) simulation files to verify the controller's state machine transitions.

## 🚀 Compilation and Simulation Guide

This workspace is fully optimized for VS Code utilizing the Icarus Verilog (iverilog) compiler toolchain and GTKWave for visual waveform debugging.

**Prerequisites**
Ensure you have the simulation binaries installed on your system terminal:

```bash  
    # Verify installations
    iverilog -v
    vvp -v
```

## 💻Execution Steps

1. **Open your Terminal at the root project directory**  
2. **Compile the Design Modules Together**
3. **Execute the Compiled Binary**
4. **Analyze the Output Waveform**

```bash
    # bash cmd
    iverilog -o sim_out.vvp rtl_design/direct_mapping.v testbench/testbench.v
    vvp sim_out.vvp
    gtkwave waveform/testbench.vcd
```