library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
-- SIGNAL
signal t_canale : STD_LOGIC_VECTOR(1 downto 0);
signal t_indirizzo : STD_LOGIC_VECTOR(15 downto 0);
signal reg_canale_load : STD_LOGIC;

begin
    --------------------------------------------
    -- Lettura canale di uscita su W
    --------------------------------------------
    -- Implemento uno shift register che permette di scorrere i due bit quando START=1. In questo caso non mi interessa avere un mux prima
    -- dell'ingresso, perchè ho lunghezza fissa, quindi leggo sempre 2 bit.
    ff0_canale: process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            t_canale(0) <= '0';
        elsif rising_edge(i_clk) then
            if(reg_canale_load = '1') then
                t_canale(0) <= i_w;
            end if;
        end if;
    end process;
    
    ff1_canale: process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                t_canale(1) <= '0';
            elsif rising_edge(i_clk) then
                if(reg_canale_load = '1') then
                    t_canale(1) <= t_canale(0);
                end if;
            end if;
        end process;
        
    --------------------------------------------
    -- Lettura dell'indirizzo su W
    --------------------------------------------
    -- Anche in questo caso implemento uno shift register per poter gestire automaticamente i bit dell'indirizzo. In questo caso invece,
    -- uso il mux perchè al momento di reg_canale_load=1, ho bisogno che tutti i bit siano a 0. Serve il padding, che mi verrà fatto automaticamente 
    -- dallo shift register.
    with reg_canale_load select
        t_indirizzo(0) <= '0' when '0',
                          i_w when '1',
                          'X' when others;
    
end Behavioral;
