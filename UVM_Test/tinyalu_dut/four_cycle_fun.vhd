--   Copyright 2013 Ray Salemi
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
-- VHDL Architecture tinyalu_lib.three_cycle.mult
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY four_cycle IS
   PORT( 
      A           : IN     unsigned ( 7 DOWNTO 0 );
      B           : IN     unsigned ( 7 DOWNTO 0 );
      clk         : IN     std_logic;
      reset_n     : IN     std_logic;
      start       : IN     std_logic;
      done_four   : OUT    std_logic;
      result_four : OUT    unsigned (15 DOWNTO 0)
   );

-- Declarations

END four_cycle ;

--
architecture fun of four_cycle is
  signal a_int,b_int : unsigned (7 downto 0);  -- start pipeline
  signal four1,four2,four3,four4 : unsigned (15 downto 0);  -- pipeline registers
  signal fourdone4,fourdone3,fourdone2,fourdone1,fourdone_mult_int : std_logic;       -- pipeline the done signal
begin
  -- purpose: four stage pipelined multiplier
  -- type   : sequential
  -- inputs : clk, reset_n, a,b
  -- outputs: result_four
  fun_proc: process (clk, reset_n)
  begin  -- process multiplier
    if reset_n = '0' then               -- asynchronous reset (active low)
      fourdone_mult_int <= '0';
      fourdone4 <= '0';
      fourdone3 <= '0';
      fourdone2 <= '0';
      fourdone1 <= '0';
      
	  a_int <= "00000000";
	  b_int <= "00000000";
    four1 <= "0000000000000000";
    four2 <= "0000000000000000";
    four3 <= "0000000000000000";
    result_four <= "0000000000000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      a_int <= a;
      b_int <= b;
      four1 <=  conv_unsigned(2,8) * a_int;
      four2 <=  conv_unsigned(3,8) * b_int;
      four3 <= four1;
      four4 <= four3 + four2;
      result_four <= four4;
      fourdone4 <= start and (not fourdone_mult_int);
      fourdone3 <= fourdone4 and (not fourdone_mult_int);
      fourdone2 <= fourdone3 and (not fourdone_mult_int);
      fourdone1 <= fourdone2 and (not fourdone_mult_int);
      fourdone_mult_int  <= fourdone1 and (not fourdone_mult_int);
    end if;
  end process fun_proc;
  done_four <= fourdone_mult_int;
end architecture fun;

