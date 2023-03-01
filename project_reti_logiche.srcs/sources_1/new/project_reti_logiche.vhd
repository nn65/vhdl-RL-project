library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start : in STD_LOGIC;
        i_w : in STD_LOGIC;
		i_mem_data : in STD_LOGIC_VECTOR(7 downto 0);
		
		m_canale_shift : in STD_LOGIC;
		m_canale_save : in STD_LOGIC;
		m_indirizzo_save : in STD_LOGIC;
		m_indirizzo_shift : in STD_LOGIC;
		m_rzx_load : in STD_LOGIC;
		m_zx_sel : in STD_LOGIC;
        
        o_z0 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z1 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z2 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z3 : out STD_LOGIC_VECTOR(7 downto 0);
        o_mem_addr : out STD_LOGIC_VECTOR(15 downto 0)
    );
end datapath;

architecture Behavioral of datapath is
-- SIGNAL
signal t_canale : STD_LOGIC_VECTOR(1 downto 0);
signal t_rz0_load : STD_LOGIC;
signal t_rz1_load : STD_LOGIC;
signal t_rz2_load : STD_LOGIC;
signal t_rz3_load : STD_LOGIC;
signal t_buffer : STD_LOGIC_VECTOR(16 downto 0);
signal t_buffer_bitwise : STD_LOGIC_VECTOR(15 downto 0);

signal t_rz0 : STD_LOGIC_VECTOR(7 downto 0);
signal t_rz1 : STD_LOGIC_VECTOR(7 downto 0);
signal t_rz2 : STD_LOGIC_VECTOR(7 downto 0);
signal t_rz3 : STD_LOGIC_VECTOR(7 downto 0);

begin

    shift: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            t_buffer <= "00000000000000000";
        elsif rising_edge(i_clk) then
--            if m_canale_save = '1' then
--                t_canale <= t_buffer(1 downto 0);
--                t_buffer(0) <= '0';
--                t_buffer(1) <= '0';
--            end if;
--            if m_indirizzo_save = '1' then
--                t_mem_addr <= t_buffer(16 downto 1);
--            end if;
            t_buffer(16 downto 1) <= t_buffer(15 downto 0);
            t_buffer(0) <= '0';
            t_buffer(0) <= i_w;
        end if;
  
    end process;
    
    process(i_clk, i_rst, m_canale_save)
    begin
        if(i_rst = '1') then
            t_buffer_bitwise <= "0000000000000000";
        elsif rising_edge(m_canale_save) then
            t_canale <= t_buffer(1 downto 0);
--            t_buffer(0) <= '0';
--            t_buffer(1) <= '0';
        end if;
        if rising_edge(i_clk) and m_canale_save = '0' then
            t_buffer_bitwise(15 downto 1) <= t_buffer_bitwise(14 downto 0);
            t_buffer_bitwise(0) <= '1';
        end if;
        if rising_edge(i_clk) and m_canale_save = '1' then
            t_buffer_bitwise <= "0000000000000000";
        end if;
    end process;
    
    process(m_indirizzo_save)
    begin
        if rising_edge(m_indirizzo_save) then
            o_mem_addr <= t_buffer(16 downto 1) and t_buffer_bitwise;
            --o_mem_addr <= t_mem_addr;
        end if;
    end process;
    
--    with m_canale_save select
--        t_buffer(0) <= '0' when '1',
--                       t_buffer(0) when '0',
--                       'X' when others;
--   with m_canale_save select
--        t_buffer(1) <= '0' when '1',
--                        t_buffer(1) when '0',
--                        'X' when others;
                       
    
    --------------------------------------------
    -- Lettura canale su W
    --------------------------------------------
    -- Implemento uno shift register che permette di scorrere i due bit quando START=1. In questo caso non mi interessa avere un mux prima
    -- dell'ingresso, perchè ho lunghezza fissa, quindi leggo sempre 2 bit.
--	canale_left_shift: process(i_clk, i_rst)
--	begin
--		if(i_rst = '1') then
--			t_canale <= "00";
--		elsif rising_edge(i_clk) and m_canale_shift='1' then
--			t_canale(1) <= t_canale(0);
--			t_canale(0) <= '0';
--			t_canale(0) <= i_w;
--		end if;
--	end process;
        
    --------------------------------------------
    -- Lettura dell'indirizzo su W
    --------------------------------------------
    -- Anche in questo caso implemento uno shift register per poter gestire automaticamente i bit dell'indirizzo a 0 dove non serve. In questo caso invece,
    -- uso il mux perchè al momento di reg_canale_load=1, ho bisogno che tutti i bit siano a 0. Serve il padding, che mi verrà fatto automaticamente 
    -- dallo shift register.
--	indirizzo_left_shift: process(i_clk, i_rst)
--	begin
--		if(i_rst = '1') then
--			t_mem_addr <= "0000000000000000";
--		elsif rising_edge(i_clk) and m_indirizzo_shift='1' then
--			t_mem_addr(15 downto 1) <= t_mem_addr(14 downto 0);
--			t_mem_addr(0) <= '0';
--			t_mem_addr(0) <= i_w;
--		end if;
--		o_mem_addr <= t_mem_addr;
--	end process;
	
	--------------------------------------------
    -- Uscita e gestione dei registri
    --------------------------------------------
	-- Creo un demultiplexer per gestire il segnale di scrittura sui registri. In questo caso uso un DEMUX per poter indirizzare il giusto canale.
	rzx_demux: process(m_rzx_load)
	begin
	   case t_canale is 
            when "00" =>
                t_rz0_load <= m_rzx_load;
                t_rz1_load <= '0';
                t_rz2_load <= '0';
                t_rz3_load <= '0';
            when "01" =>
                t_rz0_load <= '0';
                t_rz1_load <= m_rzx_load;
                t_rz2_load <= '0';
                t_rz3_load <= '0';
            when "10" =>
                t_rz0_load <= '0';
                t_rz1_load <= '0';
                t_rz2_load <= m_rzx_load;
                t_rz3_load <= '0';
            when "11" =>
                t_rz0_load <= '0';
                t_rz1_load <= '0';
                t_rz2_load <= '0';
                t_rz3_load <= m_rzx_load;
            when others =>
                t_rz0_load <= 'X';
                t_rz1_load <= 'X';
                t_rz2_load <= 'X';
                t_rz3_load <= 'X';
        end case;
	end process;
			
	-- Sistemo l'uscita cpn quello che leggo dalla memoria. Creo 4 registri diversi, perchè il valore delle uscite devono rimanere le stesse, ad eccezione dell'uscita corretta.
	rz0: process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			t_rz0 <= "00000000";
		elsif rising_edge(i_clk) then
			if(t_rz0_load = '1') then
				t_rz0 <= i_mem_data;
			end if;
		end if;
	end process;
	
	rz1: process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			t_rz1 <= "00000000";
		elsif rising_edge(i_clk) then
			if(t_rz1_load = '1') then
				t_rz1 <= i_mem_data;
			end if;
		end if;
	end process;
    
	rz2: process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			t_rz2 <= "00000000";
		elsif rising_edge(i_clk) then
			if(t_rz2_load = '1') then
				t_rz2 <= i_mem_data;
			end if;
		end if;
	end process;
	
	rz3: process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			t_rz3 <= "00000000";
		elsif rising_edge(i_clk) then
			if(t_rz3_load = '1') then
				t_rz3 <= i_mem_data;
			end if;
		end if;
	end process;
	
	-- In cascata alle uscite dei registri metto dei MUX. Questo permette di visualizzare sempre 0 quando o_done=0 (ovvero m_zx_sel = o_done).
	with m_zx_sel select
		o_z0 <= "00000000" when '0',
				t_rz0 when '1',
				"XXXXXXXX" when others;
				
	with m_zx_sel select
		o_z1 <= "00000000" when '0',
				t_rz1 when '1',
				"XXXXXXXX" when others;
				
	with m_zx_sel select
		o_z2 <= "00000000" when '0',
				t_rz2 when '1',
				"XXXXXXXX" when others;
				
	with m_zx_sel select
		o_z3 <= "00000000" when '0',
				t_rz3 when '1',
				"XXXXXXXX" when others;
	
end Behavioral;

--------------------------------------------
-- ENTITY PROJECT RETI LOGICHE
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start : in STD_LOGIC;
        i_w : in STD_LOGIC;
        
        o_z0 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z1 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z2 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z3 : out STD_LOGIC_VECTOR(7 downto 0);
        o_done : out STD_LOGIC;
        
        o_mem_addr : out STD_LOGIC_VECTOR(15 downto 0);
        i_mem_data : in STD_LOGIC_VECTOR(7 downto 0);
        o_mem_we : out STD_LOGIC;
        o_mem_en : out STD_LOGIC
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
	port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_start : in STD_LOGIC;
        i_w : in STD_LOGIC;
		i_mem_data : in STD_LOGIC_VECTOR(7 downto 0);
		
		m_canale_shift : in STD_LOGIC;
		m_canale_save : in STD_LOGIC;
		m_indirizzo_save : in STD_LOGIC;
		m_indirizzo_shift : in STD_LOGIC;
		m_rzx_load : in STD_LOGIC;
		m_zx_sel : in STD_LOGIC;
        
        o_z0 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z1 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z2 : out STD_LOGIC_VECTOR(7 downto 0);
        o_z3 : out STD_LOGIC_VECTOR(7 downto 0);
        o_mem_addr : out STD_LOGIC_VECTOR(15 downto 0)
    );
end component;
-- Chiamo i signal come il nome dei componenti per mappare automaticamente 1:1
signal m_canale_shift : STD_LOGIC;
signal m_canale_save : STD_LOGIC;
signal m_indirizzo_save : STD_LOGIC;
signal m_indirizzo_shift : STD_LOGIC;
signal m_rzx_load : STD_LOGIC;
signal m_zx_sel : STD_LOGIC;

-- Definisco la macchina a stati
type S is (S0, S1, S2, S3, S4, S5, S6, S7, S8);
signal cur_state, next_state : S;

begin
-- Istanza del datapath.
	DATAPATH0: datapath port map(
		i_clk,
		i_rst,
		i_start,
		i_w,
		i_mem_data,
		
		m_canale_shift,
		m_canale_save,
		m_indirizzo_save,
		m_indirizzo_shift,
		m_rzx_load,
		m_zx_sel,
		
		o_z0,
		o_z1,
		o_z2,
		o_z3,
		o_mem_addr
	);

	--------------------------------------------
    -- Parte di memoria. Stato iniziale di partenza al reset
    --------------------------------------------
	process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			cur_state <= S0;
		elsif rising_edge(i_clk) then
			cur_state <= next_state;
		end if;
	end process;
	
	--------------------------------------------
    -- Funzione stato prossimo
    --------------------------------------------
	process(cur_state, i_start)
	begin
		next_state <= cur_state;
		case cur_state is
			when S0 =>
				if(i_start = '1') then
					next_state <= S1;
				else
					next_state <= S0;
				end if;
			when S1 =>
				if(i_start = '1') then
					next_state <= S2;
				end if;
			when S2 =>
				if(i_start = '1') then
					next_state <= S3;
				else
					next_state <= S4;
				end if;
			when S3 =>
				if(i_start = '0') then
					next_state <= S4;
				else
					next_state <= S3;
				end if;
			when S4 =>
				next_state <= S5; -- DA RIVEREDERE. QUI DOVREI CAPIRE QUANDO LA MEMORIA EFFETTIVAMENTE MI STA FACENDO LEGGERE QUALCOSA.
			when S5 =>
				next_state <= S6;
			when S6 =>
				next_state <= S7;
			when S7 =>
				next_state <= S8;
            when S8 =>
                next_state <= S0;
        end case;
	end process;
	
	--------------------------------------------
    -- Funzione uscita
    --------------------------------------------
	process(cur_state)
	begin
		-- Segnali del datapath
		m_canale_shift <= '0';
		m_canale_save <= '0';
		m_indirizzo_save <= '0';
		m_indirizzo_shift <= '0';
		m_rzx_load <= '0';
		m_zx_sel <= '0';
		-- Segnali memoria
		o_mem_en <= '0';
		o_mem_we <= '0';
		-- Uscite primarie
		o_done <= '0';
		
		-- Assegnazione dei vari segnali quando sono nello stato desiderato
		case cur_state is
			when S0 =>
			when S1 =>
				--m_canale_shift <= '1';
			when S2 =>
				--m_canale_shift <= '1';
				m_canale_save <= '1';
			when S3 =>
				--m_indirizzo_shift <= '1';
            when S4 =>
                m_indirizzo_save <= '1';
			when S5 =>
				o_mem_en <= '1';
			when S6 =>
			when S7 =>
				m_rzx_load <= '1';
			when S8 =>
			    m_zx_sel <= '1';
				o_done <= '1';
				
        end case;
	end process;

end Behavioral;
