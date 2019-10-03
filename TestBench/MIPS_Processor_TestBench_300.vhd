
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.MyType.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY MIPS_Processor_TestBench_300 IS
END MIPS_Processor_TestBench_300;
 
ARCHITECTURE behavior OF MIPS_Processor_TestBench_300 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MIPS_Processor
    PORT(
	    clk : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        inputData: in  std_logic_vector(127 downto 0); -- input data
        inputRdy: in std_logic;
        mode_select: IN std_logic_vector(1 downto 0);
        current_PC : out  STD_LOGIC_VECTOR (31 downto 0);
        current_Inst : out  STD_LOGIC_VECTOR (31 downto 0);
        rom_data_out: out MEM;
        reg_data:out REG
        );
    END COMPONENT;
    
    signal inputData:  std_logic_vector(127 downto 0):=(others=>'0'); -- input data
    signal inputRdy: std_logic:='0';
    signal mode_select: std_logic_vector(1 downto 0) := "00";
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal current_PC : std_logic_vector(31 downto 0);
   signal current_Inst : std_logic_vector(31 downto 0);
   signal rom_data_out: MEM;
   signal reg_data:REG;

   -- Clock period definitions
   constant clk_period : time := 1 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MIPS_Processor PORT MAP (
          clk => clk,
          reset => reset,
          inputData => inputData, -- input data
          inputRdy => inputRdy,
          mode_select => mode_select,
          current_PC => current_PC,
          current_Inst => current_Inst,
          rom_data_out => rom_data_out,
          reg_data => reg_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		--clk <= '0';
		--wait for clk_period/2;
		--clk <= '1';
		--wait for clk_period/2;
		

		clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	
	
	file cmdfile:TEXT;
	variable L:Line;
	variable good:boolean;
	
	variable plaintext:std_logic_vector(63 downto 0);
	variable u_key:std_logic_vector(127 downto 0);
	variable encode_result:std_logic_vector(63 downto 0);
	variable decode_result:std_logic_vector(63 downto 0);
	

	
	-- store our output for comparison
	variable our_encode_result:std_logic_vector(63 downto 0);
	variable our_decode_result:std_logic_vector(63 downto 0);
	
   begin		
	
	
      FILE_OPEN(cmdfile,"C:\Users\Morgan\Desktop\9_1_ori\9.1\300testcases.txt",READ_MODE);
      --FILE_OPEN(cmdfile,"300testcases.txt",READ_MODE);
      loop
      if endfile(cmdfile) then
            exit;
      end if;
      readline(cmdfile,L);
      next when L'length = 0;   -- Skip empty lines

		-- read from L to variables
      hread(L, plaintext, good);
      hread(L, u_key, good);
      hread(L, encode_result, good);
      hread(L, decode_result, good);
	   wait for 2 us;
	  
      -- hold reset state for 100 ns.
      inputRdy <= '0';
      --inputData <= x"38383838383838383838383838383838";

      inputData <= u_key;
      --inputData <= x"3E0C97BEADA501D17C5E1CAD016EC5E7";
      --inputData <= x"00000000000000000000000000000000";
      wait for 2 us;
        mode_select <= "00";
		inputRdy <= '1';
		reset <= '1';
      wait for 2 us;
         --inputData <= (others => '0');
        inputRdy <= '0';
		reset <='0';
		wait for 500 us;           -- input mode
		
		mode_select <= "11";
        reset <= '1';
        wait for 2 us;
        reset <= '0';
        wait for 20000 us;        -- Key Gen
        
        inputRdy <= '0';
        --inputData <= x"0f0f0f0f0f0f0f0f0000000000000000";
        inputData <= plaintext & x"0000000000000000";
        --inputData <= x"E265973B3A38A71C0000000000000000"; 
        --inputData <= x"00000000000000000000000000000000"; 
        --inputData := input_plaintext;
        wait for 2 us;
        mode_select <= "00";
        inputRdy <= '1';
        reset <= '1';
        wait for 2 us;
        --inputData <= (others => '0');
        inputRdy <= '0';
        reset <='0';
        wait for 500 us;           -- Input
        
        mode_select <= "01";
        reset <= '1';
        wait for 2 us;
        reset <= '0';
        wait for 20000 us;        -- Encode
		  
		  -- verification process
		  our_encode_result := reg_data(1) & reg_data(2);
		  --report "our_encode_result is" & our_encode_result;
		  --assert our_encode_result = encode_result report "Encode Error." severity Error; 
		  assert our_encode_result = encode_result report "Encode Error." severity Error; 
        wait for 20ns;
        
        inputRdy <= '0';
        --inputData <= x"0f0f0f0f0f0f0f0f0000000000000000";
        inputData <= plaintext & x"0000000000000000";
        --inputData <= x"E265973B3A38A71C0000000000000000"; 
        --inputData <= x"00000000000000000000000000000000"; 
        wait for 2 us;
        mode_select <= "00";
        inputRdy <= '1';
        reset <= '1';
        wait for 2 us;
        inputData <= (others => '0');
        inputRdy <= '0';
        reset <='0';
        wait for 500 us;           -- Input
        
        mode_select <= "10";
        reset <= '1';
        wait for 2 us;
        reset <= '0';
        wait for 20000 us;        -- Decode
		  
		  -- verification process
		  our_decode_result := reg_data(1) & reg_data(2);
		  assert our_decode_result = decode_result report "Decode Error." severity Error; 
        
		

      wait for clk_period*10;
		end loop;
		
      -- insert stimulus here 

      wait;
   end process;

END;
