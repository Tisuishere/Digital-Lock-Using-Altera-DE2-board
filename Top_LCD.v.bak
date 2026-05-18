module Top_LCD (
    input            CLOCK_50,
    input  [3:0]     PASS_IN,   // Dùng để nhập từng số của mật mã
    input  [2:0]     STATUS_IN, // Dùng để chọn trạng thái hiển thị dòng 1
    // ----------------------------
    input  [2:0]     KEY,       // KEY[0]: Reset, KEY[1]: Nhập số, KEY[2]: Nạp Status
    output [7:0]     LCD_DATA,
    output           LCD_RW,
    output           LCD_EN,
    output           LCD_RS,
    output           LCD_ON
);

    // ==========================================
    // 1. KHAI BÁO BIẾN
    // ==========================================
    wire reset_n;
    wire lcd_ready;
    wire btn_digit_pressed;
    wire btn_status_pressed;

    reg  lcd_valid;
    reg  lcd_row;
    reg  [3:0] lcd_col;
    reg  [7:0] lcd_data_in;
    reg  refresh_tick; 

    reg [7:0] line1_buffer [0:15];
    reg [7:0] line2_buffer [0:15];
    reg [2:0] status_reg; 
    reg [2:0] digit_count; 

    reg btn_digit_prev;
    reg btn_status_prev;
    reg [4:0] char_idx;
    reg [1:0] disp_state;

    // ==========================================
    // 2. GÁN TÍN HIỆU & PHÁT HIỆN CẠNH
    // ==========================================
    assign reset_n = KEY[0];
    assign btn_digit_pressed  = (btn_digit_prev  == 1'b1 && KEY[1] == 1'b0);
    assign btn_status_pressed = (btn_status_prev == 1'b1 && KEY[2] == 1'b0);

    // ==========================================
    // 3. GỌI MODULE LCD CONTROLLER
    // ==========================================
    LCD_Controller u_lcd (
        .CLOCK_50(CLOCK_50), .reset_n(reset_n),
        .iValid(lcd_valid), .iRow(lcd_row), .iCol(lcd_col), .iData(lcd_data_in),
        .oReady(lcd_ready), .LCD_DATA(LCD_DATA), .LCD_RW(LCD_RW), 
        .LCD_EN(LCD_EN), .LCD_RS(LCD_RS), .LCD_ON(LCD_ON)
    );

    // ==========================================
    // 4. LOGIC XỬ LÝ NHẬP LIỆU
    // ==========================================
    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            btn_digit_prev  <= 1'b1;
            btn_status_prev <= 1'b1;
            digit_count     <= 0;
            status_reg      <= 0;
            refresh_tick    <= 1'b1;
            
            // Khởi tạo dòng 2
            line2_buffer[0]="P"; line2_buffer[1]="a"; line2_buffer[2]="s";
            line2_buffer[3]="s"; line2_buffer[4]=":"; line2_buffer[5]=" ";
            line2_buffer[6]=" "; line2_buffer[7]=" "; line2_buffer[8]=" ";
            line2_buffer[9]=" "; line2_buffer[10]=" "; line2_buffer[11]=" ";
            line2_buffer[12]=" "; line2_buffer[13]=" "; line2_buffer[14]=" "; line2_buffer[15]=" ";
        end else begin
            btn_digit_prev  <= KEY[1];
            btn_status_prev <= KEY[2];
            refresh_tick    <= 1'b0;

            // Xử lý nạp trạng thái Dòng 1 bằng KEY[2]
            if (btn_status_pressed) begin
                status_reg   <= STATUS_IN; // Đã thay SW[6:4] thành STATUS_IN
                refresh_tick <= 1'b1;
            end

            // Xử lý nhập số Dòng 2 bằng KEY[1]
            if (btn_digit_pressed) begin
                refresh_tick <= 1'b1;
                if (digit_count < 4) begin
                    // Đã thay SW[3:0] thành PASS_IN
                    line2_buffer[6 + digit_count] <= (PASS_IN < 10) ? (8'h30 + PASS_IN) : (8'h37 + PASS_IN);
                    digit_count <= digit_count + 1;
                end else begin
                    // Logic nhập số thứ 5: Xóa 4 số cũ, số mới nằm ở vị trí 1
                    line2_buffer[6] <= (PASS_IN < 10) ? (8'h30 + PASS_IN) : (8'h37 + PASS_IN);
                    line2_buffer[7] <= " "; 
                    line2_buffer[8] <= " "; 
                    line2_buffer[9] <= " ";
                    digit_count <= 1; // Đặt lại đếm là 1
                end
            end
        end
    end

    // ==========================================
    // 5. ĐỊNH NGHĨA CHUỖI KÝ TỰ DÒNG 1
    // ==========================================
    always @(*) begin
        // Xóa trắng buffer trước khi ghi để tránh ký tự rác
        line1_buffer[0]=" "; line1_buffer[1]=" "; line1_buffer[2]=" "; line1_buffer[3]=" "; 
        line1_buffer[4]=" "; line1_buffer[5]=" "; line1_buffer[6]=" "; line1_buffer[7]=" "; 
        line1_buffer[8]=" "; line1_buffer[9]=" "; line1_buffer[10]=" "; line1_buffer[11]=" "; 
        line1_buffer[12]=" "; line1_buffer[13]=" "; line1_buffer[14]=" "; line1_buffer[15]=" ";
        
        case (status_reg)
            3'd0: begin line1_buffer[0]="E"; line1_buffer[1]="n"; line1_buffer[2]="t"; line1_buffer[3]="e"; line1_buffer[4]="r"; line1_buffer[5]=" "; line1_buffer[6]="p"; line1_buffer[7]="a"; line1_buffer[8]="s"; line1_buffer[9]="s"; end
            3'd1: begin line1_buffer[0]="U"; line1_buffer[1]="n"; line1_buffer[2]="l"; line1_buffer[3]="o"; line1_buffer[4]="c"; line1_buffer[5]="k"; end
            3'd2: begin line1_buffer[0]="L"; line1_buffer[1]="o"; line1_buffer[2]="c"; line1_buffer[3]="k"; end
            3'd3: begin line1_buffer[0]="N"; line1_buffer[1]="e"; line1_buffer[2]="w"; line1_buffer[3]=" "; line1_buffer[4]="p"; line1_buffer[5]="a"; line1_buffer[6]="s"; line1_buffer[7]="s"; end
            3'd4: begin line1_buffer[0]="W"; line1_buffer[1]="r"; line1_buffer[2]="o"; line1_buffer[3]="n"; line1_buffer[4]="g"; end
            3'd5: begin line1_buffer[0]="C"; line1_buffer[1]="o"; line1_buffer[2]="r"; line1_buffer[3]="r"; line1_buffer[4]="e"; line1_buffer[5]="c"; line1_buffer[6]="t"; end
            default: begin line1_buffer[0]="I"; line1_buffer[1]="d"; line1_buffer[2]="l"; line1_buffer[3]="e"; end
        endcase
    end

    // ==========================================
    // 6. FSM QUÉT HIỂN THỊ (GIỮ NGUYÊN)
    // ==========================================
    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            disp_state <= 0; char_idx <= 0; lcd_valid <= 0;
        end else begin
            case (disp_state)
                0: if (refresh_tick && lcd_ready) begin disp_state <= 1; char_idx <= 0; end
                1: begin
						  lcd_valid <= 1'b1;
                    lcd_row   <= (char_idx < 16) ? 1'b0 : 1'b1;
                    lcd_col   <= char_idx[3:0];
                    lcd_data_in <= (char_idx < 16) ? line1_buffer[char_idx] : line2_buffer[char_idx - 16];
                    disp_state <= 2;
                end
                2: if (!lcd_ready) begin lcd_valid <= 1'b0; disp_state <= 3; end
                3: if (lcd_ready) begin
                    if (char_idx < 31) begin char_idx <= char_idx + 1; disp_state <= 1; end
                    else disp_state <= 0;
                end
            endcase
        end
    end
endmodule