# UART Protocol — RTL Design

A fully modular, synthesizable **UART (Universal Asynchronous Receiver-Transmitter)** implementation written in **Verilog HDL**. The design follows a clean datapath + control-FSM decomposition for both the transmitter and receiver paths, with independent baud-rate generators supporting multiple standard rates.

---

## Table of Contents

- [Overview](#overview)
- [UART Frame Format](#uart-frame-format)
- [Architecture](#architecture)
  - [Top-Level Block Diagram](#top-level-block-diagram)
  - [Transmitter Datapath](#transmitter-datapath)
  - [Receiver Datapath](#receiver-datapath)
  - [Baud Rate Generation](#baud-rate-generation)
- [Module Descriptions](#module-descriptions)
  - [Top Level](#top-level)
  - [Transmitter Modules](#transmitter-modules)
  - [Receiver Modules](#receiver-modules)
  - [Baud Generators](#baud-generators)
- [FSM State Diagrams](#fsm-state-diagrams)
  - [Transmitter FSM](#transmitter-fsm)
  - [Receiver FSM](#receiver-fsm)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Status](#status)

---

## Overview

| Feature            | Details                                  |
| :----------------- | :--------------------------------------- |
| **Data Width**     | 8 bits                                   |
| **Parity**         | Even parity (XOR-based)                  |
| **Stop Bits**      | 1                                        |
| **Baud Rates**     | 9600 · 19200 · 38400 · 115200 bps        |
| **Reset**          | Active-low asynchronous reset            |
| **HDL**            | Verilog (IEEE 1364-2005)                 |
| **Error Detection**| Parity error flag · Stop-bit error flag  |

---

## UART Frame Format

The design implements the standard UART frame shown below:

```
 ┌───────┬────┬────┬────┬────┬────┬────┬────┬────┬────────┬──────┐
 │ START │ D0 │ D1 │ D2 │ D3 │ D4 │ D5 │ D6 │ D7 │ PARITY │ STOP │
 │  (0)  │    │    │    │    │    │    │    │    │ (even) │  (1) │
 └───────┴────┴────┴────┴────┴────┴────┴────┴────┴────────┴──────┘
   1 bit          8 data bits (LSB first)          1 bit    1 bit
                                                  ──────────────────
                                              Total: 11 bits / frame
```

- **Start Bit** — Logic `0`, signals the beginning of a transmission.
- **Data Bits** — 8-bit payload, shifted out **LSB first**.
- **Parity Bit** — Even parity computed as `XOR` of all 8 data bits.
- **Stop Bit** — Logic `1`, marks the end of the frame.

---

## Architecture

### Top-Level Block Diagram

```
                            uart_top
            ┌──────────────────────────────────────────┐
            │                                          │
 data_in ──►│  ┌────────────┐    tx_rx    ┌──────────┐ │──► data_output
 tx_start──►│  │ uart_tx_top│───────────►│uart_rx_top│ │──► parity_error
   clock ──►│  │            │   (wire)    │          │ │──► stop_bit_error
   reset ──►│  └────────────┘             └──────────┘ │
            │                                          │
            └──────────────────────────────────────────┘
```

The top-level module `uart_top` connects the transmitter output directly to the receiver input via an internal wire (`tx_rx_wire`), forming a **loopback** test configuration. In a real deployment, this wire would be replaced by a physical serial line.

---

### Transmitter Datapath

```
                         uart_tx_top
    ┌──────────────────────────────────────────────────────┐
    │                                                      │
    │  data_in[7:0]                                        │
    │      │                                               │
    │      ├──────────►┌────────────┐                      │
    │      │           │ Parity_Gen │──── parity_bit ──┐   │
    │      │           └────────────┘                  │   │
    │      │                                           │   │
    │      └──────────►┌────────────┐                  │   │
    │                  │  Tx_PISO   │── data_out ──┐   │   │
    │                  │ (Shift Reg)│              │   │   │
    │                  └────────────┘              ▼   ▼   │
    │                       ▲              ┌────────────┐  │
    │  load, shift ─────────┘              │   Tx_Mux   │──┼──► out
    │                                      │ (4:1 sel)  │  │
    │  ┌──────────┐   sel[1:0] ───────────►└────────────┘  │
    │  │  Tx_FSM  │──── load, shift                        │
    │  │          │──── sel[1:0]                           │
    │  └──────────┘                                        │
    │      ▲                                               │
    │      │                                               │
    │  Tx_start, clk, rstn                                 │
    └──────────────────────────────────────────────────────┘
```

**Data flow:**
1. Parallel data is loaded into the **PISO shift register** (`Tx_PISO`).
2. The **FSM** (`Tx_fsm`) sequences through start → data → parity → stop states.
3. A **4:1 MUX** (`Tx_Mux`) selects the current bit to drive on the serial line:
   - `sel = 00` → Start bit (logic `0`)
   - `sel = 01` → Data bit (from PISO)
   - `sel = 10` → Parity bit
   - `sel = 11` → Stop bit / Idle (logic `1`)

---

### Receiver Datapath

```
                        uart_rx_top
    ┌──────────────────────────────────────────────────────┐
    │                                                      │
    │  Rx_in ──┬──────►┌──────────────┐                    │
    │          │       │ Detect_start │── start_detected   │
    │          │       └──────────────┘        │           │
    │          │                               ▼           │
    │          │                        ┌──────────┐       │
    │          │                        │  Rx_FSM  │       │
    │          │                        └──────────┘       │
    │          │                         │  │  │           │
    │          │              shift ─────┘  │  └── check   │
    │          │              parity_load ──┘     _stop    │
    │          │                                           │
    │          ├──────►┌──────────┐                        │
    │          │       │ Rx_SIPO  │── data_out[7:0] ──┐    │
    │          │       │(Shift Reg)│                  │    │
    │          │       └──────────┘                   │    │
    │          │                                      ▼    │
    │          ├──────►┌──────────────────┐  ┌────────┐    │
    │          │       │Rx_parity_checker │◄─┘        │    │──► parity_error
    │          │       └──────────────────┘           │    │
    │          │                                      │    │
    │          └──────►┌──────────────────┐           │    │
    │                  │stop_bit_checker  │           │    │──► stop_bit_error
    │                  └──────────────────┘           │    │
    │                                                 │    │
    │                              Rx_data_out[7:0] ◄─┘    │──► data_output
    └──────────────────────────────────────────────────────┘
```

**Data flow:**
1. **Start Detector** (`Detect_start`) monitors the line for a falling edge (logic `0`).
2. The **FSM** (`Rx_fsm`) sequences through idle → data → parity → stop states.
3. Incoming serial bits are shifted into the **SIPO register** (`Rx_SIPO`) during the data state.
4. After 8 data bits, the **Parity Checker** (`Rx_parity_checker`) validates the parity bit.
5. The **Stop Bit Checker** (`stop_bit_checker`) confirms the stop bit is logic `1`.

---

### Baud Rate Generation

Separate baud-rate generators are provided for TX and RX paths. Each generator divides the system clock to produce a 50 % duty-cycle tick at the selected rate. The RX generator uses a **higher oversampling ratio** (different divisor values) compared to the TX generator, a common technique for reliable mid-bit sampling.

| `sel[1:0]` | Baud Rate    | TX Divisor | RX Divisor |
| :--------: | :----------: | :--------: | :--------: |
| `2'b00`    | 115200 bps   | 86         | 68         |
| `2'b01`    | 38400 bps    | 260        | 208        |
| `2'b10`    | 19200 bps    | 520        | 416        |
| `2'b11`    | 9600 bps     | 1042       | 832        |

> **Note:** The default system clock frequency assumed for these divisor values is **10 MHz**.

---

## Module Descriptions

### Top Level

| Module       | File            | Description                                                    |
| :----------- | :-------------- | :------------------------------------------------------------- |
| `uart_top`   | `uart_top.v`    | Top-level wrapper connecting TX ↔ RX in loopback configuration |

### Transmitter Modules

| Module        | File                       | Description                                                        |
| :------------ | :------------------------- | :----------------------------------------------------------------- |
| `uart_tx_top` | `Transmitter/uart_tx_top.v`| TX top-level — instantiates PISO, MUX, Parity Gen, and FSM        |
| `Tx_fsm`      | `Transmitter/Tx_fsm.v`    | 5-state Mealy FSM controlling the transmit sequence                |
| `Tx_PISO`     | `Transmitter/Tx_PISO.v`   | 8-bit Parallel-In Serial-Out shift register (LSB-first)            |
| `Tx_Mux`      | `Transmitter/Tx_Mux.v`    | 4:1 multiplexer selecting start / data / parity / stop bit         |
| `Parity_Gen`  | `Transmitter/Parity_Gen.v`| Even parity generator using XOR reduction of data byte             |

### Receiver Modules

| Module               | File                              | Description                                                  |
| :------------------- | :-------------------------------- | :----------------------------------------------------------- |
| `uart_rx_top`        | `Reciever/uart_rx_top.v`         | RX top-level — instantiates all receiver sub-modules          |
| `Rx_fsm`             | `Reciever/Rx_fsm.v`              | 4-state FSM controlling the receive sequence                  |
| `Rx_SIPO`            | `Reciever/Rx_SIPO.v`             | 8-bit Serial-In Parallel-Out shift register (LSB-first)       |
| `Detect_start`       | `Reciever/Detect_start.v`        | Combinational start-bit detector (monitors for logic `0`)     |
| `Rx_parity_checker`  | `Reciever/Rx_parity_checker.v`   | Validates received parity bit against XOR of received data    |
| `stop_bit_checker`   | `Reciever/stop_bit_checker.v`    | Validates that the stop bit is logic `1`                      |

### Baud Generators

| Module               | File                   | Description                                          |
| :------------------- | :--------------------- | :--------------------------------------------------- |
| `baud_generate_tx`   | `baud_generator_tx.v`  | Clock divider for TX path (4 selectable baud rates)  |
| `baud_generator_rx`  | `baud_generator_rx.v`  | Clock divider for RX path (4 selectable baud rates)  |

---

## FSM State Diagrams

### Transmitter FSM

```
            tx_start=1
   ┌──────┐ ──────────► ┌───────────┐
   │ IDLE │              │ START_BIT │
   │ (000)│ ◄──────────  │   (001)   │
   └──────┘              └─────┬─────┘
      ▲                        │
      │                        ▼
 ┌──────────┐           ┌───────────┐
 │ STOP_BIT │           │ DATA_BIT  │◄──┐
 │  (100)   │           │   (010)   │───┘ count < 8
 └──────────┘           └─────┬─────┘
      ▲                        │ count = 8
      │                        ▼
      │                 ┌────────────┐
      └──────────────── │ PARITY_BIT │
                        │   (011)    │
                        └────────────┘
```

| State        | Encoding | `sel[1:0]` | `Load_data` | `shift` | Action                     |
| :----------- | :------: | :--------: | :---------: | :-----: | :------------------------- |
| **Idle**     | `000`    | `11`       | `0`         | `0`     | Line held high (stop/idle) |
| **Start**    | `001`    | `00`       | `1`         | `0`     | Drive `0`, load PISO       |
| **Data**     | `010`    | `01`       | `0`         | `1`     | Shift out LSB-first ×8     |
| **Parity**   | `011`    | `10`       | `1`         | `0`     | Drive parity bit           |
| **Stop**     | `100`    | `11`       | `0`         | `0`     | Drive `1` (stop bit)       |

---

### Receiver FSM

```
           start_detect=1
  ┌────────┐ ────────────► ┌───────────┐
  │  IDLE  │               │ DATA_BIT  │◄──┐
  │  (00)  │ ◄──────┐      │   (01)    │───┘ count < 8
  └────────┘        │      └─────┬─────┘
      ▲             │            │ count = 8
      │             │            ▼
      │        parity_error ┌────────────┐
      │          = 1        │PARITY_BIT  │
      │             └────── │   (10)     │
      │                     └─────┬──────┘
      │                           │ parity OK
      │                           ▼
      │                     ┌──────────┐
      └──────────────────── │ STOP_BIT │
                            │   (11)   │
                            └──────────┘
```

| State        | Encoding | `rx_shift` | `parity_load` | `check_stop` | Action                        |
| :----------- | :------: | :--------: | :-----------: | :----------: | :---------------------------- |
| **Idle**     | `00`     | `0`        | `0`           | `0`          | Wait for start detection      |
| **Data**     | `01`     | `1`        | `0`           | `0`          | Shift in serial bits ×8       |
| **Parity**   | `10`     | `0`        | `1`           | `0`          | Check parity; abort on error  |
| **Stop**     | `11`     | `0`        | `0`           | `1`          | Validate stop bit             |

---

## Directory Structure

```
UART_Protocol/
│
├── uart_top.v                  # Top-level loopback wrapper
├── baud_generator_tx.v         # TX baud rate generator
├── baud_generator_rx.v         # RX baud rate generator
│
├── Transmitter/
│   ├── uart_tx_top.v           # TX top-level module
│   ├── Tx_fsm.v               # TX control FSM
│   ├── Tx_PISO.v              # Parallel-In Serial-Out shift register
│   ├── Tx_Mux.v               # Output multiplexer
│   └── Parity_Gen.v           # Even parity generator
│
├── Reciever/
│   ├── uart_rx_top.v           # RX top-level module
│   ├── Rx_fsm.v               # RX control FSM
│   ├── Rx_SIPO.v              # Serial-In Parallel-Out shift register
│   ├── Detect_start.v         # Start-bit detector
│   ├── Rx_parity_checker.v    # Parity error checker
│   └── stop_bit_checker.v     # Stop-bit error checker
│
├── Img/                        # Diagrams & screenshots (empty)
└── README.md
```

---

## Getting Started

### Prerequisites

- Any Verilog simulator — **Xilinx Vivado**, **ModelSim**, **Icarus Verilog**, etc.

### Simulation

```bash
# Example with Icarus Verilog
iverilog -o uart_sim uart_top.v baud_generator_tx.v baud_generator_rx.v \
         Transmitter/*.v Reciever/*.v
vvp uart_sim
```

> ⚠️ **Note:** A testbench is required to drive `clock`, `reset`, `tx_start`, and `data_in`. See the [Status](#status) section below.

---

## Status

| Component            | Status         |
| :------------------- | :------------- |
| Transmitter RTL      | ✅ Complete    |
| Receiver RTL         | ✅ Complete    |
| Baud Rate Generators | ✅ Complete    |
| Top-Level Integration| ✅ Complete    |
| Design Verification  | 🔲 Pending    |

> **Design verification (testbenches, waveform analysis, coverage) has not yet been added to this repository.** This will be updated in a future commit.

---

## License

This project is open-source and available for educational purposes.
