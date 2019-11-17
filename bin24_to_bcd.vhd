------------------------------------------------------------------
--Copyright 2017 Andrey S. Ionisyan (anserion@gmail.com)
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

----------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description: generate 8-digits bcd code from 24-bit binary number
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;

entity bin24_to_bcd is
    Port ( 
		clk   : in  STD_LOGIC;
      reset : in std_logic;
      bin   : in std_logic_vector(23 downto 0);
      bcd   : out std_logic_vector(31 downto 0);
      ready : out std_logic
    );
end bin24_to_bcd;

architecture ax309 of bin24_to_bcd is
type t_pow10 is array(0 to 7) of std_logic_vector(23 downto 0);
signal pow10: t_pow10 := (
      conv_std_logic_vector(1,24),
      conv_std_logic_vector(10,24),
      conv_std_logic_vector(100,24),
      conv_std_logic_vector(1000,24),
      conv_std_logic_vector(10000,24),
      conv_std_logic_vector(100000,24),
      conv_std_logic_vector(1000000,24),
      conv_std_logic_vector(10000000,24)
      );

signal bin_reg: std_logic_vector(23 downto 0);
signal ready_reg: std_logic:='0';
begin
   ready<=ready_reg;
   process(clk)
   variable fsm: natural range 0 to 7:=0;
   variable i: natural range 0 to 15:=0;
   variable k: natural range 0 to 9:=0;
   variable N: std_logic_vector(23 downto 0):=(others=>'0');
   begin
      if rising_edge(clk) then
         case fsm is
            when 0=>
               if reset='1' then ready_reg<='0'; end if;
               i:=7; bin_reg<=bin;
               fsm:=1;
            when 1=>
               N:=pow10(i)-pow10(i-1); k:=9;
               fsm:=2;
            when 2=>
               if (bin_reg>=N)or(k=0)
               then fsm:=3;
               else N:=N-pow10(i-1); k:=k-1;
               end if;
            when 3=>
               bcd(i*4-1 downto i*4-4)<=conv_std_logic_vector(k,4);
               fsm:=4;
            when 4=>
               bin_reg<=bin_reg-N;
               if i=1
               then ready_reg<='1'; fsm:=0;
               else i:=i-1; fsm:=1;
               end if;
            when others=> null;
         end case;
      end if;
   end process;
end ax309;
