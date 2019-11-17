------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description:
-- magic low-level clocking manipulaions inside SPARTAN6 FPGA-chip
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

entity clk_core is
port(
  CLK50_ucf: in  std_logic;
  CLK100   : out std_logic;
  CLK16    : out std_logic;
  CLK8     : out std_logic;
  CLK25    : out std_logic;
  CLK12_5  : out std_logic
 );
end clk_core;

architecture ax309 of clk_core is
  signal clkin1        : std_logic;
  signal clkfbout      : std_logic;
  signal clkfbout_buf  : std_logic;
  signal clkout0       : std_logic;
  signal clkout1       : std_logic;
  signal clkout2       : std_logic;
  signal clkout3       : std_logic;
  signal clkout4       : std_logic;
  signal clkout5_unused: std_logic;
  signal locked_unused : std_logic;
begin
  -- Input buffering
  clkin1_buf : IBUFG port map (O => clkin1, I => CLK50_ucf);
  pll_base_inst : PLL_BASE
  generic map
   (BANDWIDTH            => "OPTIMIZED",
    CLK_FEEDBACK         => "CLKFBOUT",
    COMPENSATION         => "SYSTEM_SYNCHRONOUS",
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT        => 8,
    CLKFBOUT_PHASE       => 0.000,
    CLKOUT0_DIVIDE       => 4,
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT1_DIVIDE       => 25,
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT2_DIVIDE       => 50,
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT3_DIVIDE       => 16,
    CLKOUT3_PHASE        => 0.000,
    CLKOUT3_DUTY_CYCLE   => 0.500,
    CLKOUT4_DIVIDE       => 32,
    CLKOUT4_PHASE        => 0.000,
    CLKOUT4_DUTY_CYCLE   => 0.500,
    CLKIN_PERIOD         => 20.0,
    REF_JITTER           => 0.010)
  port map
   (CLKFBOUT            => clkfbout,
    CLKOUT0             => clkout0,
    CLKOUT1             => clkout1,
    CLKOUT2             => clkout2,
    CLKOUT3             => clkout3,
    CLKOUT4             => clkout4,
    CLKOUT5             => clkout5_unused,
    LOCKED              => locked_unused,
    RST                 => '0',
    CLKFBIN             => clkfbout_buf,
    CLKIN               => clkin1);

  -- Output buffering
  clkf_buf : BUFG port map (O => clkfbout_buf, I => clkfbout);
  clkout1_buf : BUFG port map (O => CLK100, I => clkout0);
  clkout2_buf : BUFG port map (O => CLK16, I => clkout1);
  clkout3_buf : BUFG port map (O => CLK8, I => clkout2);
  clkout4_buf : BUFG port map (O => CLK25, I => clkout3);
  clkout5_buf : BUFG port map (O => CLK12_5, I => clkout4);
end ax309;
