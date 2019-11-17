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
-- Description: generate 8-digits bcd code from 128-bit binary number
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;

entity bin128_to_bcd is
    Port ( 
		clk   : in  STD_LOGIC;
      reset : in std_logic;
      bin   : in std_logic_vector(127 downto 0);
      bcd   : out std_logic_vector(191 downto 0);
      ready : out std_logic
    );
end bin128_to_bcd;

architecture ax309 of bin128_to_bcd is
type t_pow10 is array(0 to 38) of std_logic_vector(127 downto 0);
signal pow10: t_pow10 := (
      conv_std_logic_vector(1,128),
      conv_std_logic_vector(10,128),
      conv_std_logic_vector(100,128),
      conv_std_logic_vector(1000,128),
      conv_std_logic_vector(10000,128),
      conv_std_logic_vector(100000,128),
      conv_std_logic_vector(1000000,128),
      conv_std_logic_vector(10**7,128),
      conv_std_logic_vector(10**8,128),
      conv_std_logic_vector(10**9,128),
      conv_std_logic_vector(10**10,128),
      conv_std_logic_vector(10**11,128),
      conv_std_logic_vector(10**12,128),
      conv_std_logic_vector(10**13,128),
      conv_std_logic_vector(10**14,128),
      conv_std_logic_vector(10**15,128),
      conv_std_logic_vector(10**16,128),
      conv_std_logic_vector(10**17,128),
      conv_std_logic_vector(10**18,128),
      conv_std_logic_vector(10**19,128),
      conv_std_logic_vector(10**20,128),
      conv_std_logic_vector(10**21,128),
      conv_std_logic_vector(10**22,128),
      conv_std_logic_vector(10**23,128),
      conv_std_logic_vector(10**24,128),
      conv_std_logic_vector(10**25,128),
      conv_std_logic_vector(10**26,128),
      conv_std_logic_vector(10**27,128),
      conv_std_logic_vector(10**28,128),
      conv_std_logic_vector(10**29,128),
      conv_std_logic_vector(10**30,128),
      conv_std_logic_vector(10**31,128),
      conv_std_logic_vector(10**32,128),
      conv_std_logic_vector(10**33,128),
      conv_std_logic_vector(10**34,128),
      conv_std_logic_vector(10**35,128),
      conv_std_logic_vector(10**36,128),
      conv_std_logic_vector(10**37,128),
      conv_std_logic_vector(10**38,128)
      );

signal ready_reg: std_logic:='0';
begin
   ready<=ready_reg;
   process(clk)
   variable fsm: natural range 0 to 15:=0;
   variable i: natural range 0 to 255:=0;
   variable k: natural range 0 to 9:=0;
   variable N: std_logic_vector(127 downto 0):=(others=>'0');
   variable bin_reg: std_logic_vector(127 downto 0);
   variable bcd_reg1: std_logic_vector(63 downto 0);
   variable bcd_reg2: std_logic_vector(63 downto 0);
   variable bcd_reg3: std_logic_vector(63 downto 0);
   begin
      if rising_edge(clk) then
         case fsm is
            when 0=>
               if reset='1' then ready_reg<='0'; end if;
               i:=18; --i:=38
               bin_reg(127 downto 32):=(others=>'0');
               bin_reg(31 downto 0):=bin(31 downto 0);
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
               if (i>0)and(i<=16)
               then bcd_reg1(i*4-1 downto i*4-4):=conv_std_logic_vector(k,4);
               end if; 
               fsm:=4;
            when 4=>
               if (i>16)and(i<=32)
               then bcd_reg2(i*4-65 downto i*4-68):=conv_std_logic_vector(k,4);
               end if;
               fsm:=5;
            when 5=>
               if (i>32)and(i<=48)
               then bcd_reg3(i*4-129 downto i*4-132):=conv_std_logic_vector(k,4);
               end if;
               fsm:=6;
            when 6=>
               bin_reg:=bin_reg-N;
               if i=1
               then
                  bcd<=bcd_reg3 & bcd_reg2 & bcd_reg1;
                  ready_reg<='1';
                  fsm:=0;
               else i:=i-1; fsm:=1;
               end if;
            when others=> null;
         end case;
      end if;
   end process;
end ax309;
