library IEEE;
use IEEE.numeric_bit.all;


-- variable assignment :=
-- signal assignment <=
-- event such as clock, clk'event

-- reset is always high (1), so we neeed to complemenet it so that we can start off with at logic 0
-- which is off

-- B3 -key0 PIN_M23
-- B2 -key1 PIN_M21
-- B1 -key2 PIN_N21


use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity wristwatch is
	port(B1, B2, B3, main_clk: in bit;
		  HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : out bit_vector (0 to 6);
		  ring_alarm ,alarm_set_disp: out bit
	);
end wristwatch;


architecture wristwatch1 of wristwatch is
	type st_type is (time_state, set_min, set_hours, alarm, set_alarm_hrs,
				set_alarm_min, stop_watch);
	
	signal state, nextstate: st_type;
	signal inch, incm, alarm_off, set_alarm, incha, incma, start_stop, reset: bit;
	
	signal disp1_input: unsigned(31 downto 0);
	signal counter : integer:=0;
	signal am_pm, aam_pm,ring, alarm_set:  bit;
	signal hours, ahours, minutes, aminutes, seconds, dispHL:  unsigned(7 downto 0);
	signal swhundreths, swseconds, swminutes:  unsigned(7 downto 0);
	signal clk :  bit;
	
	
component clock is
	port(clk, inch, incm, incha, incma, set_alarm, alarm_off: in bit;
				hours, ahours, minutes, aminutes, seconds: inout unsigned(7 downto 0);
			am_pm, aam_pm, ring, alarm_set: inout bit);
end component;

component stopwatch is
	port(clk, reset, start_stop: in bit;
		swhundreths, swseconds, swminutes: inout unsigned(7 downto 0)
	);
end component;

component bcd2seg is
	port(BCD: in unsigned(3 downto 0);
			seg : out bit_vector (6 downto 0)
	);
end component;


begin

	clock_map: clock port map(clk, inch, incm, incha, incma, set_alarm, alarm_off,
								hours, ahours, minutes, aminutes, seconds, am_pm,
								aam_pm, ring, alarm_set);
	stopwatch_map: stopwatch port map(clk, reset, start_stop, swhundreths,
								swseconds, swminutes);
	
	
	disp_hrs_hi: bcd2seg port map(hours(7 downto 4), HEX7); 			   
	disp_hrs_lo: bcd2seg port map(hours(3 downto 0), HEX6);
	disp_min_hi: bcd2seg port map(minutes(7 downto 4), HEX5);       -- SWMINUTE goes to HEX5(upper)
	disp_min_lo: bcd2seg port map(minutes(3 downto 0), HEX4);       -- SWMINUTE goes to HEX4(lower)
	disp_sec_hi: bcd2seg port map(seconds(7 downto 4), HEX3);
	disp_sec_lo: bcd2seg port map(seconds(3 downto 0), HEX2);
	disp_99_hi : bcd2seg port map(dispHL(7 downto 4), HEX1);
	disp_99_lo : bcd2seg port map(dispHL(3 downto 0), HEX0);

	
	process(state, B1, B2, B3)
	begin
		start_stop <= '0'; 		-- start_stop for stopwatch - initial 0, same for reset
		reset <= '0'; 
		alarm_off <= '0';			-- signals to set alarm and to turn off (snooze)
		set_alarm <= '0';
		
		inch <= '0'; 				-- signals to increment hours/minutes and alarm hours/minutes no value initially
		incm <= '0';  
		incha <= '0';
		incma <= '0';
			
		case state is
		when time_state =>
		
			if B1 = '1' then 
				nextstate <= alarm;
			elsif B2 = '1' then 
				nextstate <= set_hours;
			else 
				nextstate <= time_state;
			end if;
			
			if B3 = '1' then 
				alarm_off <= '1';
			end if;
			
			if am_pm = '0' then
				dispHL <= "10101111";
			else		
				dispHL <= "10111111";
			end if;
			
			
		when set_hours =>
			if B3 = '1' then 
				inch <= '1'; 
				nextstate <= set_hours;
			else 
				nextstate <= set_hours;			
			end if;
			
			if B2 = '1' then 
				nextstate <= set_min;
			end if;
			
			if am_pm = '0' then
				dispHL <= "10101111";
			else		
				dispHL <= "10111111";
			end if;
			
		when set_min =>
			if B3 = '1' then 
				incm <= '1'; 
				nextstate <= set_min;
			else 
				nextstate <= set_min;
			end if;
				if B2 = '1' then 
				nextstate <= time_state;
			end if;
			
			if am_pm = '0' then
				dispHL <= "10101111";
			else		
				dispHL <= "10111111";
			end if;
			
		when alarm =>
			if B1 = '1' then 
				nextstate <= stop_watch;
			elsif B2 = '1' then 
				nextstate <= set_alarm_hrs;
			else 
				nextstate <= alarm;		
			end if;
			
			if B3 = '1' then 
				set_alarm <= '1'; 
				nextstate <= alarm;
			end if;
			
			if aam_pm = '0' then
				dispHL <= "10101111";
			else		
				dispHL <= "10111111";
			end if;
			
		
		when set_alarm_hrs =>
			if B2 = '1' then 
				nextstate <= set_alarm_min;
			else 
				nextstate <= set_alarm_hrs;
			end if;
			
			if B3 = '1' then 
				incha <= '1';
			end if;
			
			if aam_pm = '0' then
				dispHL <= "10101111";
			else		
				dispHL <= "10111111";
			end if;
			
		when set_alarm_min =>
			if B2 = '1' then 
				nextstate <= alarm;
			else 
				nextstate <= set_alarm_min;
			end if;
			
			if B3 = '1' then 
				incma <= '1';
			end if;
			
			if aam_pm = '0' then
				dispHL <= "10101111";
			else		
				dispHL <= "10111111";
			end if;
		
		
		when stop_watch =>
			if B1 = '1' then 
				nextstate <= time_state;
			else 
				nextstate <= stop_watch;
			end if;
			
			if B2 = '1' then 
				start_stop <= '1';
			end if;
			
			if B3 = '1' then
				reset <= '1';
			end if;
			
			dispHL <= swhundreths;
			
		end case;
	end process;
	
	process(clk)
	begin
		if (rising_edge(clk)) then -- state clk
			state <= nextstate;
			ring_alarm <= ring;
		alarm_set_disp <= alarm_set;
		end if;
	end process;
	
	process (main_clk)
	begin 
		if(rising_edge(main_clk)) then
			if( counter >= 999999) then
				clk <= '1';
				counter <= 0;
			else
				counter <= counter + 1;
				clk <= '0';
		   end if;
		end if;
	end process;
end wristwatch1;