LimeSDR-PCIe-5G Board Programming
=================================

.. note::

   This procedure requires:
     * One computer equipped with LimeSDR-PCIe-5G.
     * Xilinx Vivado 2020.1 software running on the same computer.
     * An Xilinx USB programmer, e.g Xilinx JTAG Platform Cable USB II.

Hardware configuration
----------------------
    
#. Insert LimeSDR-PCIe-5G board into an available PCIe slot.
#. The board requires an additional 12V voltage supply from the computer, using the 6-pin PCIe connector J36.
#. Connect the Xilinx USB programmer JTAG cable to the J14 connector.
#. Connect the Xilinx programmer to the USB port of the computer running Vivado Xilinx software.

FPGA gateware bitstream generation
----------------------------------

The repository described below contains the FPGA gateware project for the LimeSDR_PCIe_5G board:

https://gitlab.com/myriadrf/pcie_5gradio_gw.git 

branch: DPD_3.0_Board_temp

The gateware can be built with the free version of Xilinx Vivado v2020.1 (64-bit).

In order to generate the board programming file follow the procedure: 

#. In Vivado open the gateware directory "pcie_5gradio_gw".
#. Select *Tools* |rarr| *Run Tcl script..* 
#. Execute the script "pcie_5gradio_gw/Generate_Project.tcl".
#. In Vivado press the button *Program and Debug* |rarr| *Generate bitstream*
#. After generating a gateware file, execute script "pcie_5gradio_gw/gen_prog_file.tcl" to generate configuration flash file. 
 
The file is located in: "pcie_5gradio_gw/bitstream/flash_programming_file.bin".

Uploading FPGA gateware bitstream to the FLASH memory 
----------------------------------------------------- 

#. Make sure the board is powered on and the JTAG cable is connected. 
#. Connect to the board using the Vivado Hardware manager, by clicking *Open Target* and then *Auto Connect*.
#. Add the configuration memory memory device in the Hardware Manager by selecting *Add Configuration Memory Device* and selecting the *mx25L256* part.
#. After adding the configuration memory device, in order to program it select it in the hardware tab and after right clicking select *Program Configuration Memory Device* and select the file "pcie_5gradio_gw/bitstream/flash_programming_file.bin".   
