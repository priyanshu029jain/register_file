# 📦 Entity: register_file 
* **Source Core File**: `rtl design/register_file.v`

The `register_file` module is a parameterized, dual-asynchronous-read, single-synchronous-write storage matrix designed to serve as the Core General Purpose Register (GPR) bank for RISC processing architectures. It supports concurrent instruction operand decode stages by exposing two completely independent combinational read interfaces while maintaining structural consistency via a clocked, hazard-aware write back channel.

---

## 🗺️ Architectural Logic Diagram
![Diagram](register_file.svg "Structural RTL Block Diagram of the Dual-Read Single-Write Register File")

---

## ⚙️ Generics & Parameters

These parameters control datapath width and allocation sizing during top-level instantiation:

| Generic Name | Type | Default Value | Description |
| :--- | :---: | :---: | :--- |
| **`DATA_WIDTH`** | `integer` | `8` | Bit-width dimension of individual register entries (Word length). |
| **`ADDR_WIDTH`** | `integer` | `4` | Bus width for address mapping lines (Determines index range boundaries). |

---

## 🔌 Boundary Interface Ports

| Port Name | Direction | Type | Description |
| :--- | :---: | :---: | :--- |
| **`clk`** | Input | `wire` | Master global hardware clock driving all sequential register updates. |
| **`rst_n`** | Input | `wire` | Active-low synchronous system reset signal for storage array initialization. |
| **`addr_r1`** | Input | `wire [ADDR_WIDTH-1:0]` | Parallel address selection bus targeting operand entry for Read Port 1. |
| **`data_r1`** | Output | `reg [DATA_WIDTH-1:0]` | Instantaneous combinational data payload routed out from Read Port 1. |
| **`addr_r2`** | Input | `wire [ADDR_WIDTH-1:0]` | Parallel address selection bus targeting operand entry for Read Port 2. |
| **`data_r2`** | Output | `reg [DATA_WIDTH-1:0]` | Instantaneous combinational data payload routed out from Read Port 2. |
| **`wr`** | Input | `wire` | Master synchronous Write Enable strobe bit control signal. |
| **`addr_w`** | Input | `wire [ADDR_WIDTH-1:0]` | Target address selection destination vector for clocked back-writing. |
| **`data_w`** | Input | `wire [DATA_WIDTH-1:0]` | Raw input vector payload to be latched into the register at index `addr_w`. |

---

## 🎛️ Internal Signals & Silicon Structures

| Signal Name | Type | Bit/Array Bounds | Description |
| :--- | :---: | :---: | :--- |
| **`register_bank`** | `reg` | `[DATA_WIDTH:0] [0:registers-1]` | Core memory matrix block array holding active processing configurations. |
| **`i`** | `integer` | N/A | Behavioral compiler variable iterating index rows during synchronous reset loops. |

---

## 🔢 Hardware Constants

| Constant Name | Type | Value Calculation | Description |
| :--- | :---: | :---: | :--- |
| **`registers`** | `localparam` | `2**ADDR_WIDTH` | Total volume address depth of the register cell macro (Defaults to `16` lines). |

---

## 🧬 Behavioral Core Processes

### 1. `write` — Synchronous Sequenced Matrix Write-Back
* **Execution Trigger:** Active on `@(posedge clk)` transitions.
* **Functional Mechanics:** * **Reset Condition:** When `rst_n` drops low, a parallel generation loop iterates through the macro matrix blocks to scrub data contents to zero.
  * **Destructive Filter Routing:** If `wr` is active high and the targeted pointer is valid, the data word payload is committed to memory. An address reduction validation gating logic (`|addr_w`) prevents values from modifying index entry `0`, isolating it as a constant logic ground.

### 2. `read_1` — Combinational Operand Routing Layer (Port 1)
* **Execution Trigger:** Asynchronous execution driven by sensitivity changes `@(*)`.
* **Functional Mechanics:** Continuously tracks read request indices. If `rst_n` is asserted, output is zeroed out. If the port catches a concurrent Read/Write transaction on matching coordinate cells (`addr_r1 == addr_w`), an internal **forwarding bypass loop** bypasses memory delays to route `data_w` directly to output, completely avoiding pipeline data hazards.

### 3. `read_2` — Combinational Operand Routing Layer (Port 2)
* **Execution Trigger:** Asynchronous execution driven by sensitivity changes `@(*)`.
* **Functional Mechanics:** Mirrors the execution mechanics of Port 1 across isolated mux routing blocks. It ensures that secondary operands can be concurrently evaluated and matched without inducing race conditions or bus contentions.