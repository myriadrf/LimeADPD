LimeSDR-QPCIe Board Programming
===============================

This Section describes how to program the LimeSDR-QPCIe board.

Uploading FX3 Firmware to SPI FLASH Memory 
------------------------------------------

The LimeSDR-QPCIe FX3 firmware source code, required USB drivers and software
application *CyControl.exe* are available at:

https://github.com/myriadrf/LimeSDR-QPCIe_FX3_FW

The compiled FX3 firmware (*LimeSDR-QPCIe_fx3_fw.img*) is at:

https://github.com/myriadrf/LimeSDR-QPCIe_FX3_FW/tree/master/src/Debug

In order to upload the compiled FX3 firmware into the board FLASH memory,
please, follow the procedure described below. 

* The procedure requires a computer and external 12V power supply for the
  LimeSDR-QPCIe. 
* The LimeSDR-QPCIe board is positioned outside the PC.
* The Cypress drivers must be installed first on computer.
* The connector J28 (on LimeSDR-QPCIe board) is open and external power supply
  is provided to the board. The USB3 microcontroller boots-up into bootloader
  mode.
* Short the jumper J28 and connect LimeSDR-QPCIe board to the PC using USB 3.0
  port.
* Start “CyControl.exe” application and select Cypress USB BootLoader.
* After entering into boot loader mode, there are two ways of uploading the
  firmware to USB3 microcontroller: using SPI FLASH memory or internal RAM
  memory.  Choose SPI FLASH memory option by pressing the menu command Program
  |rarr| FX3 |rarr| SPI FLASH.
  * In the status bar you will see Waiting for Cypress Boot Programmer device to
  enumerate.... and after some time window will appear.
* Select firmware image file (*LimeSDR-QPCIe_fx3_fw.img*) and press Open.
  Status bar of the USB Control Center application will indicate Programming of
  SPI FLASH in Progress….
* This message will change to the *Programming succeeded* after FLASH programming
  is done. The USB3 microcontroller will boot from FLASH memory after every
  power-on.
* Disconnect the board from computer.

PCIe IP core generation
-----------------------

Before compiling the FPGA gateware bitstream, the PCIe Xillybus IP core has to
be first generated and downloaded. 

This chapter describes all steps and parameters required to generate Xillybus
PCIe core.

* Xillybus requires filling up free registration form in order to download
  generated core. Go to link http://xillybus.com/ipfactory/signup, fill required
  fields and confirm registration via received email.
* After successful registration, go to IP core Factory page link and click *Add
  New Core*.
* Select option PCIe core and press *Next*. 
* Choose the IP core's Name, for *Target device family* select *Intel Cyclone V*,
  select *Demo bundle settings*; for operating system select *Linux and Windows*.
  Press *Create!* button.
* After new core creation is done, change the settings as specified in the Table
  1.
* After specifying all IP core parameters from Table 1 click *Generate core*.
* Check core status and download it when available.


.. list-table:: Table 1:  Xillybus PCIe IP core settings.
   :widths: 26 14 7 8 4 25
   :header-rows: 1

   * - Name
     - Direction
     - Data
     - Expected
     - Auto
     - Details

   * - **xillybus_stream0_read_32**
     - 
     -
     -
     -
     - 

   * - 
     - Upstream
     - 32 bits
     - 395 MB/s
     - No
     - Asynchronous, 512 x 16 kB = 8 MB. Data acquisition / playback.

   * - **xillybus_stream0_write_32**
     -  
     -
     -
     -
     -  

   * - 
     - Downstream 
     - 32 bits
     - 395 MB/s
     - No
     - Asynchronous, 512 x 16 kB = 8 MB. DMA acceleration: 8 segments x 512
       bytes. Data acquisition / playback.

   * - **xillybus_control0_read_32**
     -
     -
     -
     -
     -

   * - 
     - Upstream
     - 32 bits
     - 1 MB/s
     - Yes
     - General purpose.

   * - **xillybus_control0_write_32**
     -
     -
     -
     -
     -

   * - 
     - Downstream
     - 32 bits
     - 1 MB/s
     - Yes
     - General purpose.

   * - **xillybus_mem_8**
     -
     -
     -
     -
     -

   * -
     - Upstream
     - 8 bits
     - 102.400 kB/s
     - Yes
     - Address/data interface (5 address bits).

   * -
     - Downstream
     - 8 bits
     - 102.400 kB/s
     - Yes
     - Address/data interface (5 address bits).

   * - **xillybus_stream1_read_32**
     -
     -
     -
     -
     -

   * -
     - Upstream
     - 32 bits
     - 395 MB/s
     - No
     - Asynchronous, 512 x 16 kB = 8 MB. Data acquisition / playback.

   * - **xillybus_stream1_write_32**
     -
     -
     -
     -
     -

   * -
     - Downstream
     - 32 bits
     - 395 MB/s
     - No
     - Asynchronous, 512 x 16 kB = 8 MB. DMA acceleration: 8 segments x 512
       bytes. Data acquisition / playback. 

   * - **xillybus_stream2_read_32**
     -
     -
     -
     -
     -

   * -
     - Upstream
     - 32 bits
     - 395 MB/s
     - No
     - Asynchronous, 512 x 16 kB = 8 MB. Data acquisition / playback.

   * - **xillybus_stream2_write_32**
     -
     -
     -
     -
     -

   * -
     - Downstream
     - 32 bits
     - 395 MB/s
     - No
     - Asynchronous, 512 x 16 kB = 8 MB. DMA acceleration: 8 segments x 512
       bytes. Data acquisition / playback. 

FPGA gateware bitstream generation
----------------------------------

The LimeSDR-QPCIe DPD gateware project is available at:

https://github.com/myriadrf/LimeADPD/

The following tag should be checked out: **v21.07.0**

In order to generate *LimeSDR-QPCIe-lms7_trx_HW_1.2.jic* file follow the
procedure described as: 

* The Xillybus IP compressed file is first downloaded from Xillybus site. The
  compressed file contains files *xillybus.v* and *xillybus_core.qxp*.
* Place file *xillybus.v* to Quartus project directory
  *limesdr-qpcie_xillybus_core/*
* Place file *xillybus_core.qxp* to Quartus project directory
  *limesdr-qpcie_xillybus_core/*
* Open *Quartus LimeSDR-QPCIE_lms7_trx* project.
* To recompile project, press Processing |rarr| Start Compilation.
* When compilation is finished, the *LimeSDR-QPCIe-lms7_trx_HW_1.2.jic* file is
  located in gateware project directory */output_files*.

Uploading FPGA gateware bitstream to FLASH memory 
-------------------------------------------------

.. note::

   This procedure requires:
     * LimeSDR-QPCIe board inserted into PCIe slot on computer #1
     * Quartus software running on computer #2.
     * An Altera USB Blaster.

* Insert LimeSDR-QPCIe board into computer #1. Make sure that computer is turned
  off while inserting board.
* Board is programmed using JTAG header J26. Connect one end of download cable
  (e.g Altera USB Blaster) to LimeSDR-QPCIe board J26 connector and other end to
  USB port on the computer #2 running Quartus software.
* Turn on computer #1 and interrupt the boot sequence to bring up the BIOS
  System Setup interface.
* Run Quartus software in computer #2 and select Tools |rarr| Programmer.
* Click Hardware Setup.. button and select your download cable, click Close
* Click *Add File..* and select the \*.jic file 
* Pre compiled bitstream can be found in
  *DPD/gw/LimeSDR-QPCIe-lms7_trx_HW_1.2.jic*
* If you have generated your own bitstream then your file is located in gateware
  project directory */output_files*.
* Select *Program/configure* and click *Start*. After successful programming turn
  off computer #1.
* FPGA boots from programmed FLASH memory automatically when computer #1 is
  turned on.
