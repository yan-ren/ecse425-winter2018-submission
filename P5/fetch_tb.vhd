--ECSE 425 Lab 3 Cache Testbench
--Tara Tabet	260625552
--Shi Yu Liu	260683360
--Edward Yu	260617063
--Ryan Ren	260580535

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_tb is
end fetch_tb;

architecture behavior of fetch_tb is

component fetch is
generic(
    ram_size : INTEGER := 1024
);
port(
  clock : in std_logic;

	branch_address : in std_logic_vector (31 downto 0);
	branch_taken : in std_logic;
	
	next_address : out std_logic_vector (31 downto 0);
	IR : out std_logic_vector (31 downto 0);
	next_IR : out std_logic_vector (31 downto 0);
	branch_next : out std_logic;
	BUF_0 : out std_logic_vector (33 downto 0);
	BUF_1 : out std_logic_vector (33 downto 0);
	BUF_2 : out std_logic_vector (33 downto 0);
	BUF_3 : out std_logic_vector (33 downto 0);
	BUF_4 : out std_logic_vector (33 downto 0);
	BUF_5 : out std_logic_vector (33 downto 0)
);
end component;

	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal	branch_address : std_logic_vector (31 downto 0);
signal	branch_taken : std_logic;
	
signal	next_address : std_logic_vector (31 downto 0);
signal	IR : std_logic_vector (31 downto 0);
signal i : integer := 0;
signal next_IR : std_logic_vector (31 downto 0);
signal	branch_next : std_logic;
signal BUF_0 : std_logic_vector (33 downto 0);
signal	BUF_1 : std_logic_vector (33 downto 0);
signal	BUF_2 : std_logic_vector (33 downto 0);
signal	BUF_3 : std_logic_vector (33 downto 0);
signal	BUF_4 : std_logic_vector (33 downto 0);
signal	BUF_5 : std_logic_vector (33 downto 0);

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: fetch
port map(
    clock => clk,

	  branch_address => branch_address,
  	 branch_taken => branch_taken,
	
	  next_address => next_address,
	  IR => IR,
	  next_IR => next_IR,
	  branch_next => branch_next,
	  BUF_0 => BUF_0,
	  BUF_1 => BUF_1,
	  BUF_2 => BUF_2,
	  BUF_3 => BUF_3,
	  BUF_4 => BUF_4,
	  BUF_5 => BUF_5
);


				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin
    
-- put your tests here
	i <= 0;
  branch_taken <= '0';
  if (i =0) then
    reset <= '1';
    WAIT FOR 3*clk_period;
  end if;  
	
	
	reset <= '0';
	
	
	if(i <50) then
	  i <= i+1;
	  if(i = 20) then
	  branch_address <= "00000000000000000000000000010110";	
	  branch_taken <= '1';
	  end if;
	  WAIT FOR clk_period;
	end if;
	
	
end process;
	
end;
