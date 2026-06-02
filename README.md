# AMBA APB3 Dual-Slave Architecture

A robust Verilog implementation of the AMBA Advanced Peripheral Bus (APB) protocol. This project features a single APB master communicating with two independent, zero-wait-state memory slaves, complete with address decoding, read multiplexing, and `PSLVERR` exception handling.

## Features

* **APB3 Protocol Compliance:** Implements standard APB signals including `PREADY` for wait-state management and `PSLVERR` for transaction error reporting.
* **Dual-Slave Routing:** Custom top-level address decoder utilizing the 9th address bit (`paddr[8]`) to actively route transactions to distinct 256-byte slave memory arrays.
* **Zero-Wait-State Slaves:** Slave logic is purely reactive and combinational, bypassing state-machine lag to complete transactions in exactly one clock cycle.
* **Hardware Memory Protection:** Slaves are designed to actively block unauthorized write attempts to reserved memory addresses (`0xF0` to `0xFF`), instantly triggering an APB error flag.

## Project Structure

* **`top_apb.v`**: The integration layer. Contains the Address Decoder (routes `PSEL` to the correct slave) and the Read/Error Multiplexers (routes the active slave's `PRDATA`, `PREADY`, and `PSLVERR` back to the master).
* **`apb_master.v`**: The APB Master interface. Uses a standard 3-state FSM (`IDLE`, `SETUP`, `ACCESS`) to drive bus transactions and latch slave responses.
* **`apb_slave.v`**: The reactive APB Slave interface. Contains a 256-byte RAM array and handles read/write logic completely synchronously with the bus control signals.

## Architecture Overview

The system uses a 9-bit address bus to manage multiple slaves without requiring the slaves to know their own base addresses.

```text
                        +-------------------+
                        |                   |
                        |    APB Master     |
                        |                   |
                        +---------+---------+
                                  | 9-bit paddr
                                  v
                        +-------------------+
                        |                   |
                        |  Address Decoder  |
                        |  & Multiplexer    |
                        |                   |
                        +----+---------+----+
           paddr[8] == 0     |         |     paddr[8] == 1
         +-------------------+         +-------------------+
         |                                                 |
+--------v--------+                               +--------v--------+
|                 |                               |                 |
|   APB Slave 1   |                               |   APB Slave 2   |
|  (0x00 - 0xFF)  |                               |  (0x00 - 0xFF)  |
|                 |                               |                 |
+-----------------+                               +-----------------+
