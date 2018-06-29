-- physical debounce test for my Spartan6 'chinese special' devbrd

library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity top is
  port( btn1_in, btn2_in, btn3_in : in  std_logic;   --< buttons to debounce
        sw1_in, sw2_in            : in  std_logic;   --< bypass for each button
        clk50m_in                 : in  std_logic;
        ld1_out, ld2_out          : out std_logic ); --< debounced/bypassed output of btn's
end entity;

architecture arch of top is

  constant cnt       : integer := 50_000_000; --< 1s debounce at 50MHz clock rate
  constant cntrwidth : integer := 26;         --< log_2(cnt) = 26 bits needed

  component debounce is
    generic( cntrwidth : integer range 31 downto 2 );
    port( d_in           : in  std_logic;
          cnt_in         : in  unsigned(cntrwidth-1 downto 0);
          bypass_in      : in  std_logic;
          clk_in, rst_in : in  std_logic;
          q_out          : out std_logic );
  end component;

begin

  -- btn1 path
  btn1_debounce : debounce
    generic map( cntrwidth=>cntrwidth )
    port map( d_in=>btn1_in,
              cnt_in=>to_unsigned(cnt,cntrwidth),
              bypass_in=>sw1_in,
              clk_in=>clk50m_in, rst_in=>btn3_in,
              q_out=>ld1_out );
  -- btn2 path
  btn2_debounce : debounce
    generic map( cntrwidth=>cntrwidth )
    port map( d_in=>btn2_in,
              cnt_in=>to_unsigned(cnt,cntrwidth),
              bypass_in=>sw2_in,
              clk_in=>clk50m_in, rst_in=>btn3_in,
              q_out=>ld2_out );

end architecture;