`timescale 1ns/1ps
module tb_Lock_Controller();
    reg CLOCK_50, reset_n, key_valid;
    reg [3:0] key_data;
    
    wire [2:0] lcd_status;
    wire update_digit, update_status;

    Lock_Controller uut (
        .CLOCK_50(CLOCK_50), .reset_n(reset_n),
        .key_data(key_data), .key_valid(key_valid),
        .lcd_status(lcd_status), .update_digit(update_digit),
        .update_status(update_status)
    );

    always #10 CLOCK_50 = ~CLOCK_50; // Xung 50MHz

    // Task nh?p 1 phím
    task press_key(input [3:0] val);
        begin
            @(negedge CLOCK_50); 
            key_data = val;
            key_valid = 1;
            #60;                 // Giu phim 3 chu ky
            key_valid = 0;
            #300;                // Cho mach xu ly
        end
    endtask

    initial begin
        CLOCK_50 = 0; reset_n = 1; key_valid = 0; key_data = 0;
        
        // Reset m?ch
        #15 reset_n = 0; #20 reset_n = 1; 
        #100;

        $display("--- KICH BAN 1: NHAP DUNG MAT KHAU (0000) ---");
        press_key(4'h0); press_key(4'h0); press_key(4'h0); press_key(4'h0);
        #200; // lcd_status chuyen sang 1 (UNLOCK)

        $display("--- KICH BAN 2: DOI MAT KHAU MOI THANH (1234) ---");
        press_key(4'hE); // Nhan '*' de doi Pass (lcd_status = 3 - NEW PASS)
        #100;
        press_key(4'h1); press_key(4'h2); press_key(4'h3); press_key(4'h4);
        press_key(4'hE); // Nhan '*' de luu (Ve lai ENTER PASS)
        #200;

        $display("--- KICH BAN 3: DANG NHAP BANG MAT KHAU MOI ---");
        press_key(4'h1); press_key(4'h2); press_key(4'h3); press_key(4'h4);
        #200; // lcd_status phai chuyen sang 1 (UNLOCK)
        press_key(4'hF); // Nhan '#' de khoa cua lai
        #200;

        $display("--- KICH BAN 4: NHAP SAI VA BI PHAT KHOA HE THONG ---");
        // Sai lan 1 (0000) -> Wrong (4) -> Cho 3s ve lai (0)
        press_key(4'h0); press_key(4'h0); press_key(4'h0); press_key(4'h0);
        #500; 
        // Sai lan 2 (1111) -> Wrong (4) -> Cho 3s ve lai (0)
        press_key(4'h1); press_key(4'h1); press_key(4'h1); press_key(4'h1);
        #500;
        // Sai lan 3 (2222) -> Wrong (4) -> Cho 3s ve lai (0)
        press_key(4'h2); press_key(4'h2); press_key(4'h2); press_key(4'h2);
        #500;
        // Sai lan 4 (3333) -> KHOA 15 GIAY (lcd_status = 2)
        press_key(4'h3); press_key(4'h3); press_key(4'h3); press_key(4'h3);
        
        // Luc nay he thong roi vao trang thai S2_LOCK_PENALTY
        // Nguoi dung co tinh bam phim cung se bi he thong bo qua
        #100;
        press_key(4'h1); press_key(4'h2);
        
        // Cho thoi gian phat 15s troi qua...
        #2000; 
        
        $display("--- KET THUC MO PHONG ---");
        $stop;
    end
endmodule