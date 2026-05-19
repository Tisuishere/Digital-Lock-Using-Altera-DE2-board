library verilog;
use verilog.vl_types.all;
entity keypad_scanner is
    port(
        clk             : in     vl_logic;
        col             : in     vl_logic_vector(3 downto 0);
        row             : out    vl_logic_vector(3 downto 0);
        data_out        : out    vl_logic_vector(3 downto 0);
        valid           : out    vl_logic
    );
end keypad_scanner;
