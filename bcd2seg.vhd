library IEEE;
use IEEE.numeric_bit.all;

entity bcd2seg is
	port(BCD: in unsigned(3 downto 0);	
	     seg: out bit_vector (6 downto 0)); 
end bcd2seg;

		 

architecture convert of bcd2seg is

-- Output Definitions              abcdefg 
Constant sevseg_0 : bit_vector := "0000001";
Constant sevseg_1 : bit_vector := "1001111";
Constant sevseg_2 : bit_vector := "0010010";
Constant sevseg_3 : bit_vector := "0000110";
Constant sevseg_4 : bit_vector := "1001100";
Constant sevseg_5 : bit_vector := "0100100";
Constant sevseg_6 : bit_vector := "0100000";
Constant sevseg_7 : bit_vector := "0001111";
Constant sevseg_8 : bit_vector := "0000000";
Constant sevseg_9 : bit_vector := "0001100";
Constant blank : bit_vector := "1111111";
Constant seg_AM : bit_vector := "0001000";
Constant seg_PM : bit_vector := "0011000";

begin
	process (bcd)
	begin 
  		case (BCD)  is
	 		WHEN "0000"	 => seg <= sevseg_0;
	 		WHEN "0001"	 => seg <= sevseg_1;
	 		WHEN "0010"	 => seg <= sevseg_2;
	 		WHEN "0011"	 => seg <= sevseg_3;
	 		WHEN "0100"	 => seg <= sevseg_4;
	 		WHEN "0101"	 => seg <= sevseg_5;
	 		WHEN "0110"	 => seg <= sevseg_6;
	 		WHEN "0111"	 => seg <= sevseg_7;
	 		WHEN "1000"   => seg <= sevseg_8;
	 		WHEN "1001"	 => seg <= sevseg_9;
			when "1010" => seg <= seg_AM;
			When "1011" => seg <= seg_PM;
			when others => seg <= blank;
   	end case;
 	end process;
end convert;
