library verilog;
use verilog.vl_types.all;
entity Lock_System_Top is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(0 downto 0);
        COL             : in     vl_logic_vector(3 downto 0);
        ROW             : out    vl_logic_vector(3 downto 0);
        LCD_DATA        : out    vl_logic_vector(7 downto 0);
        LCD_RW          : out    vl_logic;
        LCD_EN          : out    vl_logic;
        LCD_RS          : out    vl_logic;
        LCD_ON          : out    vl_logic
    );
end Lock_System_Top;
