`timescale 1ns/1ps
module tb_Top_LCD();
    reg CLOCK_50;
    reg [3:0] PASS_IN;
    reg [2:0] STATUS_IN;
    reg [2:0] KEY;
    
    wire [7:0] LCD_DATA;
    wire LCD_RW, LCD_EN, LCD_RS, LCD_ON;

    // Gi? nguyên 100% code Top_LCD.v, không s?a gì c?
    Top_LCD uut (
        .CLOCK_50(CLOCK_50), .PASS_IN(PASS_IN), .STATUS_IN(STATUS_IN),
        .KEY(KEY), .LCD_DATA(LCD_DATA), .LCD_RW(LCD_RW), 
        .LCD_EN(LCD_EN), .LCD_RS(LCD_RS), .LCD_ON(LCD_ON)
    );

    always #10 CLOCK_50 = ~CLOCK_50; // Xung 50MHz

    // Task nh?p s? vào Dòng 2
    task lcd_input_digit(input [3:0] digit);
        begin
            @(negedge CLOCK_50);
            PASS_IN = digit;
            KEY[1] = 0; // B?m nút nh?p s? (Active-Low)
            #100;       // Gi? nút 1 chút
            KEY[1] = 1; // Nh? nút
            #3000;      // Ch? FSM quét ??y d? li?u ra buffer
        end
    endtask

    // Task ??i tr?ng thái hi?n th? Dòng 1
    task lcd_change_status(input [2:0] new_status);
        begin
            @(negedge CLOCK_50);
            STATUS_IN = new_status;
            KEY[2] = 0; // B?m nút ??i tr?ng thái
            #100; 
            KEY[2] = 1; // Nh? nút
            #10000;     // Ch? FSM quét xóa m?ng và in chu?i m?i
        end
    endtask

    initial begin
        // 1. Kh?i t?o các giá tr? ban ??u
        CLOCK_50 = 0; 
        KEY = 3'b111; 
        PASS_IN = 0; 
        STATUS_IN = 0;
        
        // =========================================================
        // TUY?T CHIÊU: DÙNG L?NH FORCE ?? ?ÁNH L?A H? TH?NG
        // =========================================================
        // L?nh này ép c?ng tín hi?u lcd_ready bên trong module uut lên m?c 1.
        // FSM s? b?t ??u quét in ch? ngay l?p t?c mà không c?n ch? 15 mili-giây.
        force uut.lcd_ready = 1'b1;

        $display("--- KHOI DONG HE THONG ---");
        #20 KEY[0] = 0; // Nh?n Reset
        #20 KEY[0] = 1; // Nh? Reset
        #500;
        
        $display("--- KICH BAN 1: NHAP DAY SO VAO DONG 2 ---");
        lcd_input_digit(4'h1); // Hi?n th? s? 1
        lcd_input_digit(4'h2); // Hi?n th? s? 2
        lcd_input_digit(4'h3); // Hi?n th? s? 3
        lcd_input_digit(4'h4); // Hi?n th? s? 4
        
        $display("--- KICH BAN 2: CAP NHAT TRANG THAI DONG 1 ---");
        lcd_change_status(3'd1); // ??i thành UNLOCK
        lcd_change_status(3'd3); // ??i thành NEW PASS
        lcd_change_status(3'd4); // ??i thành WRONG
        lcd_change_status(3'd0); // V? l?i ENTER PASS
        
        $display("--- KET THUC TEST ---");
        $stop;
    end
endmodule