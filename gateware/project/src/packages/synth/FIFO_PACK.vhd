-- ----------------------------------------------------------------------------
-- FILE:          FIFO_PACK.vhd
-- DESCRIPTION:   Package for functions related to altera FIFO
-- DATE:          12:29 PM Wednesday, August 29, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------
package FIFO_PACK is

   function FIFORD_SIZE (wr_width : integer; rd_width : integer; wr_size : integer)
      return integer;
      
   function FIFOWR_SIZE (wr_width : integer; rd_width : integer; rd_size : integer)
      return integer;
      
   function FIFO_WORDS_TO_Nbits (n_words : integer; add_msb : boolean)
      return integer;
   
   -- Outputs from the FIFO.
   type t_FROM_FIFO is record
      wrfull   : std_logic;          -- Write full flag
      wrempty  : std_logic;          -- Write empty flag
      wrusedw  : std_logic_vector(31 downto 0);    -- Write used words 
      q        : std_logic_vector(255 downto 0);   -- Read data
      rdempty  : std_logic;          -- Read empty flag
      rdusedw  : std_logic_vector(31 downto 0);
   end record t_FROM_FIFO; 

   -- Inputs to the FIFO.
   type t_TO_FIFO is record
      wrreq    : std_logic;         -- Write request
      data     : std_logic_vector(255 downto 0);  -- Write data
      rdreq    : std_logic;         -- Read request
   end record t_TO_FIFO;
   
   -- Initialize FIFO ports with constants
   constant c_FROM_FIFO_INIT : t_FROM_FIFO := ( wrfull   => '0',
                                                wrempty  => '1',
                                                wrusedw  => (others=> '0'),
                                                q        => (others=> '0'),
                                                rdempty  => '1',
                                                rdusedw  => (others => '0')
                                                );
                                                
   constant c_TO_FIFO_INIT : t_TO_FIFO := (  wrreq => '0',
                                             data  => (others=> '0'),
                                             rdreq => '0'
                                             );                                               

   
end  FIFO_PACK;

-- ----------------------------------------------------------------------------
-- Package body
-- ----------------------------------------------------------------------------
package body FIFO_PACK is

-- ----------------------------------------------------------------------------
-- Return FIFO rdusedw size, up to 4 times difference in port width
-- ----------------------------------------------------------------------------
   function FIFORD_SIZE (wr_width : integer; rd_width : integer; wr_size : integer)  
      return integer is     
   begin  
      if wr_width > rd_width then 
         return wr_size+(wr_width/rd_width)/2;
      elsif wr_width < rd_width then 
         return wr_size-(rd_width/wr_width)/2;
      else 
         return wr_size;
      end if;     
   end FIFORD_SIZE;
   
-- ----------------------------------------------------------------------------
-- Return FIFO wrusedw size, up to 4 times difference in port width
-- ----------------------------------------------------------------------------
   function FIFOWR_SIZE (wr_width : integer; rd_width : integer; rd_size : integer)  
      return integer is     
   begin  
      if rd_width > wr_width then 
         return rd_size+(rd_width/wr_width)/2;
      elsif rd_width < wr_width then 
         return rd_size-(wr_width/rd_width)/2;
      else 
         return rd_size;
      end if;     
   end FIFOWR_SIZE;
   
-- ----------------------------------------------------------------------------
-- Return FIFO required bits to represent number of words
-- ---------------------------------------------------------------------------- 
   function FIFO_WORDS_TO_Nbits (n_words : integer; add_msb : boolean)  
      return integer is     
   begin 
      if add_msb then 
         return integer(ceil(log2(real(n_words))))+1;
      else 
         return integer(ceil(log2(real(n_words))));
      end if;
   end FIFO_WORDS_TO_Nbits;
end FIFO_PACK;
      
      