module Lock_System_Top (
    input  wire       CLOCK_50,
    input  wire [0:0] KEY,      // KEY[0] làm nút Reset toàn hệ thống
    input  wire [3:0] COL,      // Tín hiệu cột từ Keypad
    output wire [3:0] ROW,      // Tín hiệu hàng ra Keypad
    
    // Các chân giao tiếp phần cứng LCD
    output wire [7:0] LCD_DATA,
    output wire       LCD_RW,
    output wire       LCD_EN,
    output wire       LCD_RS,
    output wire       LCD_ON
);

    // ==========================================
    // 1. KHAI BÁO BIẾN NỘI BỘ
    // ==========================================
    wire reset_n = KEY[0];
    wire clk_1kHz;
    wire [3:0] key_data;
    wire key_valid;
    
    wire [2:0] ctrl_lcd_status;
    wire       ctrl_update_digit;
    wire       ctrl_update_status;

    // ==========================================
    // 2. KHỞI TẠO CÁC MODULE CON
    // ==========================================
    
    // Tạo xung 1kHz cho Keypad quét ma trận
    clk_divider u_clk_div (
        .clk_in(CLOCK_50),
        .clk_out(clk_1kHz)
    );

    // Module đọc bàn phím
    keypad_scanner u_scanner (
        .clk(clk_1kHz),
        .col(COL),
        .row(ROW),
        .data_out(key_data),
        .valid(key_valid)
    );

    // Khối điều khiển Trung tâm (FSM)
    Lock_Controller u_control (
        .CLOCK_50(CLOCK_50),
        .reset_n(reset_n),
        .key_data(key_data),
        .key_valid(key_valid),
        .lcd_status(ctrl_lcd_status),
        .update_digit(ctrl_update_digit),
        .update_status(ctrl_update_status)
    );

    // Khối điều khiển LCD
    // Đảo chiều tín hiệu (~) từ Control để tạo xung cạnh xuống giả lập nút bấm cho LCD
    wire [2:0] simulated_key;
    assign simulated_key[0] = reset_n;
    assign simulated_key[1] = ~ctrl_update_digit;  
    assign simulated_key[2] = ~ctrl_update_status; 

    Top_LCD u_lcd_display (
        .CLOCK_50(CLOCK_50),
        .PASS_IN(key_data),            
        .STATUS_IN(ctrl_lcd_status),   
        .KEY(simulated_key),           
        .LCD_DATA(LCD_DATA),
        .LCD_RW(LCD_RW),
        .LCD_EN(LCD_EN),
        .LCD_RS(LCD_RS),
        .LCD_ON(LCD_ON)
    );

endmodule