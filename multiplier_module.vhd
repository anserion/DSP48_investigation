------------------------------------------------------------------
--Copyright 2019 Andrey S. Ionisyan (anserion@gmail.com)
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--    http://www.apache.org/licenses/LICENSE-2.0
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.
------------------------------------------------------------------

------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description:
-- DSP multiplier test module.
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplier_module is
   Port (
      clk : in STD_LOGIC;
      latency_n : in std_logic_vector(15 downto 0);
      mult_op1,mult_op2 : in std_logic_vector(63 downto 0);
      mult_res : out std_logic_vector(127 downto 0);
      multiplier_ask: in STD_LOGIC;
      multiplier_ack: out STD_LOGIC;
      multiplier_ready: out STD_LOGIC
	);
end multiplier_module;

architecture ax309 of multiplier_module is
begin
   res1_process:
   process (clk)
   variable fsm:natural range 0 to 3 := 0;
   variable i:std_logic_vector(15 downto 0):=(others=>'0');
   variable mult_op1_reg:std_logic_vector(55 downto 0):=(others=>'0');
   variable mult_op2_reg:std_logic_vector(55 downto 0):=(others=>'0');
   variable mult_res_reg:std_logic_vector(111 downto 0):=(others=>'0');
   begin
      if rising_edge(clk) then
         case fsm is
         when 0 =>
            if multiplier_ask='1' then
               multiplier_ready<='0';
               multiplier_ack<='1';
               fsm:=1;
            end if;
         when 1=>
               mult_op1_reg:=mult_op1(55 downto 0);
               mult_op2_reg:=mult_op2(55 downto 0);
               multiplier_ack<='0';
               i:=(others=>'0');
               fsm:=2;
         when 2=>
            mult_res_reg:=mult_op1_reg*mult_op2_reg;
            fsm:=3;
         when 3 =>
            if i=latency_n then
               mult_res(127 downto 112)<=(others=>'0');
               mult_res(111 downto 0)<=mult_res_reg;
               multiplier_ready<='1';
               fsm:=0;
            else i:=i+1;
            end if;
         when others => fsm:=0;
         end case;
      end if;
   end process;
end ax309;