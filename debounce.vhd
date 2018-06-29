---
 -- Copyright (c) 2018 Sean Stasiak. All rights reserved.
 -- Developed by: Sean Stasiak <sstasiak@protonmail.com>
 -- Refer to license terms in LICENSE; In the absence of such a file,
 -- contact me at the above email address and I can provide you with one.
---
library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity debounce is
  generic( cntrwidth : integer range 31 downto 2 );
  port( d_in           : in  std_logic;
        cnt_in         : in  unsigned(cntrwidth-1 downto 0);
        bypass_in      : in  std_logic;
        clk_in, rst_in : in  std_logic;
        q_out          : out std_logic );
end entity;

architecture arch of debounce is
  signal d : std_logic;
  signal cnt : unsigned(cntrwidth-1 downto 0);
  type state_t is ( trail_hold, trail_wait, lead_hold, lead_wait );
  signal state : state_t;
begin

  q_out <= d_in when bypass_in = '1' else d;

  process(clk_in, rst_in)
  begin
    if rst_in = '1' then
      state <= trail_hold;
      d <= d_in;
    elsif rising_edge(clk_in) then
      if d_in /= d then
        case state is
          when trail_hold =>
            cnt <= cnt_in;
            state <= lead_wait;
          when trail_wait =>
            if cnt > 2 then   --< 'hide' latency (only works for cnts of 1+)
              cnt <= cnt - 1; --  this is why the cntr is a minimum of 2 bits
              state <= trail_wait;
            else
              d <= d_in;
              state <= trail_hold;
            end if;
          when lead_hold =>
            cnt <= cnt_in;
            state <= trail_wait;
          when lead_wait =>
            if cnt > 2 then   --< 'hide' latency (only works for cnts of 1+)
              cnt <= cnt - 1; --  this is why the cntr is a minimum of 2 bits
              state <= lead_wait;
            else
              d <= d_in;
              state <= lead_hold;
            end if;
          when others =>
            d <= d_in;
            state <= trail_hold;
        end case;
      else --< d_in = d
        case state is
          when trail_wait =>
            state <= lead_hold;
          when lead_wait =>
            state <= trail_hold;
          when others =>
            state <= state;
        end case;
      end if;
    end if;
  end process;

end architecture;