--Test Ps2 port, for reading the keyboard input
--
--This program uses the ps2Interface and the sevenSegmentDisplayInterface entities to display in the
--seven segment display the hex code recived, the program also sends the code recived in binary form
--through paralel comunication to an arduino to later processing the data recived. The program also
--do this because there are occasions where the speed of the hex codes recived is faster than the
--posibilities to be readed on the segment display, so they are processed and printed to the serial
--monitor by an arduino.
--
--The code has been tested for the Cyclone IV (EP4CE6E22C8N)
--
--The code is for the 16Bit computer, by Pablo Rivero Lazaro
library IEEE;
use IEEE.std_logic_1164.all;

entity TestPS2 is
	generic (
		filter_length: positive := 8;
		refresh_counter_lenght: positive := 20
	);
	port (

		--General ports
		clk: in std_logic; --The clock of the cpu
		rst: in std_logic; --The reset signal of the cpu

		--PS2 ports
		ps2_clk: in std_logic; --The clock of the ps2 port
		ps2_data: in std_logic; --The data of the ps2 port

		--Seven segment display ports
		digits_activated: out std_logic_vector(3 downto 0); --Every digit if it is activated or not, active_low
		segments_activated: out std_logic_vector(6 downto 0); --Every segment if is activates or not, active_low

		--Indicator lights
		valid_flag: out std_logic;
		error_flag: out std_logic;

		--Data output for arduino testing
		data_out: out std_logic_vector(7 downto 0)
	);
end TestPS2;

architecture Behavioral of TestPS2 is

signal ps2_parsed_data: std_logic_vector(7 downto 0);
signal ps2_data_valid: std_logic;
signal ps2_data_error: std_logic;

signal recived_data: std_logic_vector(15 downto 0);

begin
	
	--Assigning the entity ps2Interface to the correspondent pins
	ps2: entity work.ps2Interface
		generic map(
			filter_length  => filter_length
		)
		port map(
			clk			=> clk,
			rst			=> rst,
			ps2_clk		=> ps2_clk,
			ps2_data	=> ps2_data,
			data		=> ps2_parsed_data,
			data_valid	=> ps2_data_valid,
			data_error	=> ps2_data_error);


	--Assigning the entity sevenSegementDisplayInterface to the correspondent pins
	sevenSegmentDisplay: entity work.sevenSegmentDisplayInterface
		generic map(
			refresh_counter_lenght => refresh_counter_lenght
		)
		port map(
			clk 				=> clk,
			rst					=> rst,
			number				=> recived_data,
			digits_activated	=> digits_activated,
			segments_activated	=> segments_activated);

	--Main process to show the data recived
	process(clk, rst)
	begin
		if rst = '0' then
			error_flag <= '0';
			valid_flag <= '0';
			recived_data <= (others => '0');
			data_out <= (others => '0');

		elsif rising_edge(clk) then
			if ps2_data_valid = '1' then --The data is valid
				error_flag <= '0';
				valid_flag <= '1';
				recived_data <= "00000000" & ps2_parsed_data;
				data_out <= ps2_parsed_data;

			end if;
			if ps2_data_error = '1' then --The data has an error
				error_flag <= '1';

			end if;
			if ps2_data_valid = '0' then --The data is not valid
				valid_flag <= '0';

			end if;
		end if;
	end process;

end Behavioral;
