module Lock_Controller (
    input  wire       CLOCK_50,
    input  wire       reset_n,
    
    input  wire [3:0] key_data,
    input  wire       key_valid,
    
    output reg  [2:0] lcd_status,
    output reg        update_digit,
    output reg        update_status
);

    // Mật khẩu mặc định 0-0-0-0
    reg [15:0] saved_pass = 16'h0000; 
    reg [15:0] entered_pass;

    // Định nghĩa các trạng thái (Khớp với STATUS_IN của LCD)
    localparam S0_ENTER_PASS = 3'd0;
    localparam S1_UNLOCK     = 3'd1;
    localparam S2_LOCK_PENALTY= 3'd2; // Trạng thái bị khóa 15s
    localparam S3_NEW_PASS   = 3'd3;
    localparam S4_WRONG      = 3'd4;

    reg [2:0] state;
    reg [2:0] digit_count;
    reg [2:0] wrong_count;    // Đếm số lần nhập sai

    // Cài đặt bộ định thời (Timer) dựa trên Clock 50MHz
    localparam [29:0] TIME_3S  = 30'd150_000_000;
    localparam [29:0] TIME_15S = 30'd750_000_000;
    reg [29:0] delay_timer;

    // --- Dò xung cạnh lên của phím bấm ---
    reg valid_sync1, valid_sync2, valid_prev;
    wire key_pressed_pulse;
    
    always @(posedge CLOCK_50) begin
        valid_sync1 <= key_valid;
        valid_sync2 <= valid_sync1;
        valid_prev  <= valid_sync2;
    end
    assign key_pressed_pulse = (valid_sync2 && !valid_prev);

    // --- FSM ĐIỀU KHIỂN ---
    // Chú ý: Không dùng 'negedge reset_n' ở đây để có thể phớt lờ reset khi bị phạt
    always @(posedge CLOCK_50) begin
        // Tự động xóa xung trigger cho LCD
        if (update_digit)  update_digit  <= 0;
        if (update_status) update_status <= 0;

        // Xử lý Reset đồng bộ: Nếu bấm Reset và KHÔNG PHẢI đang bị phạt 15s
        if (!reset_n && state != S2_LOCK_PENALTY) begin
            state         <= S0_ENTER_PASS;
            lcd_status    <= S0_ENTER_PASS;
            digit_count   <= 0;
            wrong_count   <= 0;
            entered_pass  <= 0;
            delay_timer   <= 0;
            update_status <= 1;
        end else begin
            case (state)
                // S0: ĐỢI NHẬP MẬT KHẨU
                S0_ENTER_PASS: begin
                    if (key_pressed_pulse && key_data >= 4'h0 && key_data <= 4'h9) begin
                        entered_pass <= {entered_pass[11:0], key_data}; // Dịch số mới vào
                        digit_count  <= digit_count + 1;
                        update_digit <= 1;
                        
                        // Đã nhập đủ 4 số
                        if (digit_count == 3) begin 
                            if ({entered_pass[11:0], key_data} == saved_pass) begin
                                state       <= S1_UNLOCK;
                                lcd_status  <= S1_UNLOCK;
                                wrong_count <= 0; // Reset bộ đếm sai
                            end else begin
                                wrong_count <= wrong_count + 1;
                                // Nếu sai lần thứ 4 -> Khóa 15s (S2)
                                if (wrong_count == 3) begin
                                    state      <= S2_LOCK_PENALTY;
                                    lcd_status <= S2_LOCK_PENALTY;
                                end else begin
                                    // Sai dưới 4 lần -> Hiện chữ Wrong 3s (S4)
                                    state      <= S4_WRONG;
                                    lcd_status <= S4_WRONG;
                                end
                            end
                            update_status <= 1;
                            digit_count   <= 0;
                            delay_timer   <= 0;
                        end
                    end
                end

                // S1: MỞ KHÓA THÀNH CÔNG
                S1_UNLOCK: begin
                    if (key_pressed_pulse) begin
                        if (key_data == 4'hE) begin // Phím '*' (E): Đổi mật khẩu
                            state        <= S3_NEW_PASS;
                            lcd_status   <= S3_NEW_PASS;
                            update_status<= 1;
                            entered_pass <= 0;
                            digit_count  <= 0;
                        end
                        else if (key_data == 4'hF) begin // Phím '#' (F): Chủ động khóa lại
                            state        <= S0_ENTER_PASS;
                            lcd_status   <= S0_ENTER_PASS;
                            update_status<= 1;
                            entered_pass <= 0;
                        end
                    end
                end

                // S3: NHẬP MẬT KHẨU MỚI
                S3_NEW_PASS: begin
                    if (key_pressed_pulse) begin
                        // Nhập số
                        if (key_data >= 4'h0 && key_data <= 4'h9 && digit_count < 4) begin
                            entered_pass <= {entered_pass[11:0], key_data};
                            digit_count  <= digit_count + 1;
                            update_digit <= 1;
                        end
                        // Xác nhận lưu mật khẩu bằng phím '*' khi đã nhập đủ 4 số
                        else if (key_data == 4'hE && digit_count == 4) begin
                            saved_pass   <= entered_pass; // Lưu đè mật khẩu mới
                            state        <= S1_UNLOCK;
                            lcd_status   <= S1_UNLOCK;
                            update_status<= 1;
                        end
                    end
                end

                // S4: NHẬP SAI (Chờ 3s)
                S4_WRONG: begin
                    if (delay_timer < TIME_3S) begin
                        delay_timer <= delay_timer + 1;
                    end else begin
                        state        <= S0_ENTER_PASS;
                        lcd_status   <= S0_ENTER_PASS;
                        update_status<= 1;
                        entered_pass <= 0;
                    end
                end

                // S2: PHẠT KHÓA HỆ THỐNG (Chờ 15s)
                S2_LOCK_PENALTY: begin
                    if (delay_timer < TIME_15S) begin
                        delay_timer <= delay_timer + 1;
                    end else begin
                        state        <= S0_ENTER_PASS;
                        lcd_status   <= S0_ENTER_PASS;
                        wrong_count  <= 0;  // Xóa tội, cho phép nhập lại
                        update_status<= 1;
                        entered_pass <= 0;
                    end
                end

                default: state <= S0_ENTER_PASS;
            endcase
        end
    end
endmodule