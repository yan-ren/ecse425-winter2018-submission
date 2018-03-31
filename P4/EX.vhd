library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity EX is
  port(
	clk : in std_logic;
	IR_addr_out : in std_logic_vector(31 DOWNTO 0);
	funct : in std_logic_vector(5 DOWNTO 0);
	opcode : in std_logic_vector(5 DOWNTO 0);
	rs: in std_logic_vector(31 downto 0);
	rt: in std_logic_vector(31 downto 0);
	rt_out:	out std_logic_vector(31 downto 0);
	signExtImm : in std_logic_vector(31 DOWNTO 0);
	result: out std_logic_vector(31 downto 0);
	des_addr_in : in std_logic_vector(4 DOWNTO 0);
	des_addr_out : OUT std_logic_vector(4 DOWNTO 0);
	bran_taken: out std_logic:= '0';
	jump_addr : in std_logic_vector(25 DOWNTO 0);
	sf : out std_logic_vector(63 downto 0);
	branch_addr: out std_logic_vector(31 downto 0)
	--zero: out std_logic := '0'
  );
end EX;

architecture behavioral of EX is
	signal hilo : std_logic_vector(63 downto 0);
	signal hi : std_logic_vector(31 downto 0);
	signal lo : std_logic_vector(31 downto 0);
	signal output : std_logic_vector(31 downto 0);
	--signal temp_ALU_out : std_logic_vector(3 downto 0);
	signal pc_plus_4 : std_logic_vector(31 downto 0):= (others =>'0');
	signal temp_bran_taken: std_logic:= '0';
	signal temp_branch_addr: std_logic_vector(31 downto 0):= (others =>'0');
	--signal data0 : std_logic_vector(31 downto 0):= (others =>'0');


begin

pc_plus_4 <= std_logic_vector((unsigned(IR_addr_out))+ 4);


ALU_control_process : process(opcode, funct,rs,rt,pc_plus_4,signExtImm,jump_addr,clk)
	begin
		if rising_edge(clk) then
		case opcode is

			-- R type instruction
			when "000000" =>

				case funct is

					-- add
					when "100000" =>
						output<= std_logic_vector(signed(rs) + signed(rt)); --ADD
						temp_bran_taken <= '0';

					-- sub
					when "100010" =>
						output<= std_logic_vector(signed(rs) - signed(rt)); --SUB
						temp_bran_taken <= '0';

					-- mult
					when "011000" =>
						hilo <= std_logic_vector(signed(rs) * signed(rt)); --MUL change
						temp_bran_taken <= '0';
						hi<= hilo(63 downto 32);
 						lo<= hilo(31 downto 0);
						output<=hilo(31 downto 0); 

					-- div
					when "011010" =>
						--hilo <= std_logic_vector(signed(rs) mod signed(rt)) & std_logic_vector(signed(rs) / signed(rs));
						output <= std_logic_vector(signed(rs) / signed(rt));
						lo<=output;
						hi <= std_logic_vector(signed(rs) mod signed(rt));
						temp_bran_taken <= '0';
						--hi<= hilo(63 downto 32);
 						--lo<= hilo(31 downto 0);
						--output<=lo;
						
					-- slt
					when "101010" =>
						temp_bran_taken <= '0';
						if (signed(rs) < signed(rt)) then
							output <= "00000000000000000000000000000001";
						else
							output <= "00000000000000000000000000000000";
						end if;					

					-- and
					when "100100" =>
						output <= rs AND rt;
						temp_bran_taken <= '0';

					-- or
					when "100101" =>
						output <= rs OR rt;
						temp_bran_taken <= '0';

					-- nor
					when "100111" =>
						output <= rs NOR rt;
						temp_bran_taken <= '0';

					-- xor
					when "100110" =>
						output <= rs XOR rt;
						temp_bran_taken <= '0';

					-- mfhi
					when "010000" =>
						output <= hi;
						temp_bran_taken <= '0';

					-- mflo
					when "010010" =>
						output <= lo;
						temp_bran_taken <= '0';

					-- sll
					when "000000" =>
						output <= std_logic_vector(signed(rt) sll to_integer(signed(signExtImm(10 downto 6))));
						temp_bran_taken <= '0';

					-- srl
					when "000010" =>
						output <= std_logic_vector(signed(rt) srl to_integer(signed(signExtImm(10 downto 6))));
						temp_bran_taken <= '0';

					-- sra
					when "000011" =>
						output <= std_logic_vector(shift_right(signed(rt) , to_integer(signed(signExtImm(10 downto 6)))));
						temp_bran_taken <= '0';

					--jr
					when "001000" =>
						output<=(others => '0');
						temp_branch_addr <= rs;
              					temp_bran_taken <= '1';


					when others =>
						output <=(others => '0');
						temp_bran_taken <= '0';

				end case; 

			-- I type
			-- slti
			when "001010" =>
				temp_bran_taken <= '0';
				if (signed(rs) < signed(signExtImm)) then
					output <= "00000000000000000000000000000001";
				else
					output <= "00000000000000000000000000000000";
				end if;				
			--ADDi
			when "001000"  =>
				temp_bran_taken <= '0';
                                output<= std_logic_vector(signed(rs) + signed(signExtImm)); --ADD

			-- andi
			when "001100" =>
				output <= rs AND signExtImm;
				temp_bran_taken <= '0';

			-- ori
			when "001101" =>
				output <= rs OR signExtImm;
				temp_bran_taken <= '0';

			-- xori
			when "001110" =>
				output <= rs XOR signExtImm;
				temp_bran_taken <= '0';

			-- lui
			when "001111" =>
				output <= to_stdlogicvector(to_bitvector(signExtImm) sll 16);
				temp_bran_taken <= '0';

			-- beq
			when "000100" =>
				 temp_branch_addr <= pc_plus_4 + std_logic_vector(unsigned(signExtImm)sll  2);
       				 if(rs = rt) then
         				 temp_bran_taken <= '1';
        			 else
         				 temp_bran_taken <= '0';
        			 end if;

			-- bne
			when "000101" =>
				temp_branch_addr <= pc_plus_4 + std_logic_vector(unsigned(signExtImm)sll  2);
       				 if(rs = rt) then
         				 temp_bran_taken <= '0';
        			 else
         				 temp_bran_taken <= '1';
        			 end if;

			-- j
          		when "000010" =>
          			temp_branch_addr (31 downto 28) <= pc_plus_4(31 downto 28);
		        	temp_branch_addr (27 downto 2) <= jump_addr;
          			temp_branch_addr(1 downto 0) <= "00";
           			temp_bran_taken <= '1';
        		-- jal
           		when "000011" =>
          			temp_branch_addr (31 downto 28) <= pc_plus_4(31 downto 28);
           			temp_branch_addr (27 downto 2) <= jump_addr;
           			temp_branch_addr(1 downto 0) <= "00";
           			temp_bran_taken <= '1';
          		
			-- sw
			when "101011" =>
				output<= std_logic_vector(signed(rs) + signed(signExtImm)); 
				temp_bran_taken <= '0';

			-- lw
			when "100011" =>
				output<= std_logic_vector(signed(rs) + signed(signExtImm)); 
				temp_bran_taken <= '0';

			when others =>
				output <=(others => '0');
				temp_bran_taken <= '0';
            			temp_branch_addr <=(others => '0');
				--null;

		end case;

		bran_taken<= temp_bran_taken;
		branch_addr <= temp_branch_addr;
		result <= output;
		des_addr_out<=des_addr_in;
		rt_out<= rt;
		sf<=hilo;
end if;
	end process;


end behavioral;