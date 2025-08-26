import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_fifo(dut):
    dut._log.info("Start FIFO Test")

    # Start system clock (100 kHz = 10 us period)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Global reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    dut._log.info("Global reset released")

    # Apply FIFO-specific resets (wrst_n and rrst_n)
    dut.uio_in[4].value = 0  # wrst_n = 0
    dut.uio_in[3].value = 0  # rrst_n = 0
    await ClockCycles(dut.clk, 10)
    dut.uio_in[4].value = 1  # wrst_n = 1
    dut.uio_in[3].value = 1  # rrst_n = 1
    dut._log.info("FIFO write/read resets released")

    # ---- Test 1: Write one value ----
    test_val = 0xAB
    dut.ui_in.value = test_val
    dut.uio_in[7].value = 1   # winc = 1
    await ClockCycles(dut.clk, 10)
    dut.uio_in[7].value = 0   # stop writing
    dut._log.info(f"Wrote {hex(test_val)} into FIFO")

    # ---- Test 2: Read the value ----
    dut.uio_in[6].value = 1   # rinc = 1
    await ClockCycles(dut.clk, 30)
    dut.uio_in[6].value = 0   # stop reading
    read_val = int(dut.uo_out.value)
    dut._log.info(f"Read {hex(read_val)} from FIFO")
    await ClockCycles(dut.clk, 10)
    # Check correctness
    assert read_val == test_val, f"FIFO mismatch! wrote {hex(test_val)}, got {hex(read_val)}"

    # ---- Test 3: Check empty flag ----
    await ClockCycles(dut.clk, 100)
    assert dut.uio_out[0].value == 1, "FIFO should be empty after reading"
