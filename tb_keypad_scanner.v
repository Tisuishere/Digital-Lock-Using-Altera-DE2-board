`timescale 1ms/1us
module tb_keypad_scanner();
    reg clk;
    reg [3:0] col;
    wire [3:0] row;
    wire [3:0] data_out;
    wire valid;

    // Gi? nguyên code g?c c?a b?n, không s?a 1 ch? nào
    keypad_scanner uut (
        .clk(clk), .col(col), .row(row), 
        .data_out(data_out), .valid(valid)
    );

    always #0.5 clk = ~clk; // Xung clock 1kHz (Chu k? 1ms)

    // Task t? ??ng gi? l?p phím b?m ??ng b? v?i s??n âm ?? tránh nhi?u
    task simulate_button_press(
        input [3:0] wait_row, // Giá tr? row ?ANG HI?N DI?N khi FSM ? State t??ng ?ng
        input [3:0] col_pull
    );
        begin
            wait(row == wait_row); 
            @(negedge clk); // ??i s??n âm ?? ch?t tín hi?u an toàn
            col = col_pull; // Kéo c?t xu?ng (Gi? l?p b?m phím)
            #5;             // Gi? phím trong 5ms
            col = 4'b1111;  // Nh? phím
            #10;            // ??i FSM ?n ??nh
        end
    endtask

    initial begin
        clk = 0; 
        col = 4'b1111; 
        
        $display("--- BAT DAU TEST MODULE KEYPAD (Giu nguyen Code goc) ---");
        #5;

        // FSM State 00: Ch?a logic phím 0, *, #, D
        // Lúc này chân row ?ANG gi? giá tr? 0111 (c?a State 11 tr??c ?ó)
        $display("1. Test Phim '0' (Trong State 00)");
        simulate_button_press(4'b0111, 4'b1101); // K? v?ng data_out = 0000

        // FSM State 01: Ch?a logic phím 1, 2, 3, A
        // Lúc này chân row ?ANG gi? giá tr? 1110 (c?a State 00)
        $display("2. Test Phim '1' (Trong State 01)");
        simulate_button_press(4'b1110, 4'b1110); // K? v?ng data_out = 0001
        
        // FSM State 10: Ch?a logic phím 4, 5, 6, B
        // Lúc này chân row ?ANG gi? giá tr? 1101 (c?a State 01)
        $display("3. Test Phim '5' (Trong State 10)");
        simulate_button_press(4'b1101, 4'b1101); // K? v?ng data_out = 0101

        // FSM State 11: Ch?a logic phím 7, 8, 9, C
        // Lúc này chân row ?ANG gi? giá tr? 1011 (c?a State 10)
        $display("4. Test Phim '9' (Trong State 11)");
        simulate_button_press(4'b1011, 4'b1011); // K? v?ng data_out = 1001

        $display("--- KET THUC TEST ---");
        $stop;
    end
endmodule