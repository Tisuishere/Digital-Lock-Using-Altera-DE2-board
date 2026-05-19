library verilog;
use verilog.vl_types.all;
entity LCD_Controller is
    port(
        CLOCK_50        : in     vl_logic;
        reset_n         : in     vl_logic;
        iValid          : in     vl_logic;
        iRow            : in     vl_logic_vector(0 downto 0);
        iCol            : in     vl_logic_vector(3 downto 0);
        iData           : in     vl_logic_vector(7 downto 0);
        oReady          : out    vl_logic;
        LCD_DATA        : out    vl_logic_vector(7 downto 0);
        LCD_RW          : out    vl_logic;
        LCD_EN          : out    vl_logic;
        LCD_RS          : out    vl_logic;
        LCD_ON          : out    vl_logic
    );
end LCD_Controller;
