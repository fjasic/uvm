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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tinyalu is
  port(
    A       : in  unsigned ( 7 downto 0 );
    B       : in  unsigned ( 7 downto 0 );
    clk     : in  std_logic;
    op      : in  std_logic_vector ( 2 downto 0 );
    reset_n : in  std_logic;
    start   : in  std_logic;
    done    : out std_logic;
    result  : out unsigned ( 15 downto 0 )
    );

-- Declarations

end tinyalu;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;

architecture rtl of tinyalu is

  -- Architecture declarations

  -- Internal signal declarations
  signal done_aax    : std_logic;
  signal done_mult   : std_logic;
  signal done_four   : std_logic;
  signal result_aax  : unsigned(15 downto 0);
  signal result_mult : unsigned(15 downto 0);
  signal result_four : unsigned(15 downto 0);
  signal start_single : std_logic;      -- Start signal for single cycle ops
  signal start_mult : std_logic;        -- start signal for multiply
  signal start_four : std_logic;        -- start signal for multiply and 


  -- Implicit buffer signal declarations
  signal done_internal : std_logic;


  -- Component Declarations

  component single_cycle
    port (
      A           : in  unsigned ( 7 downto 0 );
      B           : in  unsigned ( 7 downto 0 );
      clk         : in  std_logic;
      op          : in  std_logic_vector ( 2 downto 0 );
      reset_n     : in  std_logic;
      start       : in  std_logic;
      done_aax    : out std_logic;
      result_aax  : out unsigned (15 downto 0)
      );
  end component;
  component three_cycle
    port (
      A           : in  unsigned ( 7 downto 0 );
      B           : in  unsigned ( 7 downto 0 );
      clk         : in  std_logic;
      reset_n     : in  std_logic;
      start       : in  std_logic;
      done_mult   : out std_logic;
      result_mult : out unsigned (15 downto 0)
      );
  end component;

  component four_cycle
  port (
    A           : IN     unsigned ( 7 DOWNTO 0 );
    B           : IN     unsigned ( 7 DOWNTO 0 );
    clk         : IN     std_logic;
    reset_n     : IN     std_logic;
    start       : IN     std_logic;
    done_four   : OUT    std_logic;
    result_four : OUT    unsigned (15 DOWNTO 0)
    );
end component;

  -- Optional embedded configurations
  -- pragma synthesis_off
  for all : single_cycle use entity work.single_cycle;
  for all : three_cycle use entity work.three_cycle;
  for all : four_cycle use entity work.four_cycle;
  -- pragma synthesis_on


begin

-- purpose: This block shunts the start signal to the correct block. 
-- The multiply only sees the start signal when op(2) is '1'
-- type   : combinational
-- inputs : op(2),start
-- outputs: start_mult, start_single
start_demux: process (op(2),start)
begin  -- process start_demux
  case op(2) is
    when '0' =>
      start_single <= start;
      start_mult   <= '0';
      start_four <= '0';
    when '1' =>
    if op(0) = '0' then
      start_single <= '0';
      start_mult <= start;
      start_four <= '0';
    else
      start_single <= '0';
      start_mult <= '0';
      start_four <= start;
    end if;
    when others => null;
  end case;
   
end process start_demux;
  

  result_mux : process(result_aax, result_mult, result_four, op)
  begin
    case op(2) is
      when '0' => result <= result_aax;
      when '1' =>
      if op(0) = '0' then
       result <= result_mult;
      else 
        result <=result_four;
        end if;
      when others  => result <= (others => '0');
    end case;
  end process result_mux;


  done_mux : process(done_aax, done_mult,done_four, op)
  begin
    case op(2) is
      when '0' => done_internal <= done_aax;
      when '1' => 
      if op(0) = '0' then
        done_internal <= done_mult;
      else
        done_internal <= done_four;
      end if;
      when others  => done_internal <= '0';
    end case;
  end process done_mux;

  -- Instance port mappings.

  add_and_xor : single_cycle
    port map (
      A           => A,
      B           => B,
      clk         => clk,
      op          => op,
      reset_n     => reset_n,
      start       => start_single,
      done_aax    => done_aax,
      result_aax  => result_aax
      );
  mult        : three_cycle
    port map (
      A           => A,
      B           => B,
      clk         => clk,
      reset_n     => reset_n,
      start       => start_mult,
      done_mult   => done_mult,
      result_mult => result_mult
      );

      fun        : four_cycle
    port map (
      A           => A,
      B           => B,
      clk         => clk,
      reset_n     => reset_n,
      start       => start_four,
      done_four   => done_four,
      result_four => result_four
      );

  -- Implicit buffered output assignments
  done <= done_internal;

end rtl;
