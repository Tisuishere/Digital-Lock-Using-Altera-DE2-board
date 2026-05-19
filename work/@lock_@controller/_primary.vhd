library verilog;
use verilog.vl_types.all;
entity Lock_Controller is
    port(
        CLOCK_50        : in     vl_logic;
        reset_n         : in     vl_logic;
        key_data        : in     vl_logic_vector(3 downto 0);
        key_valid       : in     vl_logic;
        lcd_status      : out    vl_logic_vector(2 downto 0);
        update_digit    : out    vl_logic;
        update_status   : out    vl_logic
    );
end Lock_Controller;
