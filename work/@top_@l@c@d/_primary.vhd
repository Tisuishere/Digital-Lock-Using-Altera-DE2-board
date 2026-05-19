library verilog;
use verilog.vl_types.all;
entity Top_LCD is
    port(
        CLOCK_50        : in     vl_logic;
        PASS_IN         : in     vl_logic_vector(3 downto 0);
        STATUS_IN       : in     vl_logic_vector(2 downto 0);
        KEY             : in     vl_logic_vector(2 downto 0);
        LCD_DATA        : out    vl_logic_vector(7 downto 0);
        LCD_RW          : out    vl_logic;
        LCD_EN          : out    vl_logic;
        LCD_RS          : out    vl_logic;
        LCD_ON          : out    vl_logic
    );
end Top_LCD;
