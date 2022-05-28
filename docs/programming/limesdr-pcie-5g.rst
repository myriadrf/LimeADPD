LimeSDR-PCIe-5G Board Programming
=================================

.. note::

   This procedure requires:
     * One computer equipped with LimeSDR_PCIe_5G board inserted into PCIe slot
     * Xilinx Vivado 2020.1 software running on the same computer.
     * An Xilinx USB programmer (e.g Xilinx JTAG Platform Cable USB II Programmer).

.. note::
    
    * Insert LimeSDR_PCIe_5G board into PCIe slot of computer. Make sure that computer is turned
      off while inserting board.
    * The LimeSDR_PCIe_5G requires additional 12V voltage supply from the computer, over 6-pin PCIe connector J36.
    * The board is programmed using JTAG header connector J14. 
    * Connect the JTAG cable of Xilinx USB programmer to J14 connector of LimeSDR_PCIe_5G board. 
    * The programmer is connected over USB port to the computer running Vivado Xilinx software.   

FPGA gateware bitstream generation
----------------------------------

The repository described below contains the FPGA gateware project for the LimeSDR_PCIe_5G board:

https://gitlab.com/myriadrf/pcie_5gradio_gw.git 

branch: DPD_3.0_Board_temp

The gateware can be built with the free version of the Xilinx Vivado v2020.1 (64-bit).

In order to generate board programming file follow the procedure described as: 

* Open the Vivado in the gateware directory "pcie_5gradio_gw".
* Select *Tools* |rarr| *Run Tcl script..* 
* Execute the script "pcie_5gradio_gw/Generate_Project.tcl".
* In Vivado press the button *Program and Debug* |rarr| *Generate bitstream*
* After completing a gateware files execute script "pcie_5gradio_gw/gen_prog_file.tcl" 
  to generate configuration flash file. The file is located in:
  "pcie_5gradio_gw/bitstream/flash_programming_file.bin" 

Uploading FPGA gateware bitstream to the FLASH memory 
----------------------------------------------------- 

* Make sure the board is powered on and the JTAG cable is connected. 
* Connect to the board using the Vivado Hardware manager, by clicking *Open Target* and then *Auto Connect*.
* Add the configuration memory memory device in the Hardware Manager by selecting 
  *Add Configuration Memory Device* and selecting the *mx25L256* part.
* After adding the configuration memory device, in order to program it 
  select it in the hardware tab and after right clicking select 
  *Program Configuration Memory Device* and select the file "pcie_5gradio_gw/bitstream/flash_programming_file.bin".   
