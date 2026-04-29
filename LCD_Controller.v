module LCD_Controller(
    input            CLOCK_50,
    input            reset_n,
    // Giao tiếp với Logic bên ngoài
    input            iValid,   // Xung cho phép ghi
    input  [0:0]     iRow,     // Dòng 0 hoặc 1
    input  [3:0]     iCol,     // Cột 0-15
    input  [7:0]     iData,    // Mã ASCII
    output reg       oReady,   // Sẵn sàng nhận dữ liệu mới
    // Giao tiếp với LCD cứng
    output reg [7:0] LCD_DATA,
    output wire      LCD_RW,
    output reg       LCD_EN,
    output reg       LCD_RS,
    output wire      LCD_ON
);

    // --- Chia xung nhịp (Tạo xung 2kHz cho LCD) ---
    reg [15:0] clk_count;
    reg clk_1k;
    localparam [15:0] MAX_CLK = 16'd25000; 

    always @(posedge CLOCK_50) begin
        if (clk_count < MAX_CLK) clk_count <= clk_count + 1;
        else begin
            clk_count <= 0;
            clk_1k <= ~clk_1k;
        end
    end

    // --- FSM States ---
    localparam  INIT         = 3'd0,
                INIT_HOLD    = 3'd1,
                IDLE         = 3'd2,
                SET_POS      = 3'd3,
                SET_POS_HOLD = 3'd4,
                SEND         = 3'd5,
                SEND_HOLD    = 3'd6;

    reg [2:0] state;
    reg [3:0] count; 

    assign LCD_ON = 1'b1;
    assign LCD_RW = 1'b0;

    // --- Main Control FSM ---
    always @(posedge clk_1k or negedge reset_n) begin
        if (!reset_n) begin
            state  <= INIT;
            count  <= 0;
            oReady <= 1'b0;
            LCD_EN <= 1'b0;
        end else begin
            case (state)
                // Bước 1: Gửi lệnh khởi tạo
                INIT: begin
                    case (count)
                        4'd0: LCD_DATA <= 8'h38;
                        4'd1: LCD_DATA <= 8'h38;
                        4'd2: LCD_DATA <= 8'h38;
                        4'd3: LCD_DATA <= 8'h38;
                        4'd4: LCD_DATA <= 8'h08; // Tắt màn hình
                        4'd5: LCD_DATA <= 8'h01; // Xóa màn hình
                        4'd6: LCD_DATA <= 8'h06; // Tăng con trỏ
                        4'd7: LCD_DATA <= 8'h0C; // Bật màn hình, tắt con trỏ
                        default: LCD_DATA <= 8'h00;
                    endcase
                    LCD_EN <= 1'b1;
                    LCD_RS <= 1'b0;
                    state  <= INIT_HOLD;
                end

                INIT_HOLD: begin
                    LCD_EN <= 1'b0; // Kéo EN xuống 0 để chốt lệnh
                    if (count < 7) begin
                        count <= count + 1;
                        state <= INIT;
                    end else begin
                        state <= IDLE;
                    end
                end

                // Bước 2: Chờ tín hiệu từ Top Module
                IDLE: begin
                    oReady <= 1'b1; // Báo hiệu đã sẵn sàng
                    if (iValid) begin
                        oReady <= 1'b0; // Báo bận
                        state  <= SET_POS;
                    end
                end

                // Bước 3: Cài đặt vị trí con trỏ
                SET_POS: begin
                    if (iRow == 0) LCD_DATA <= 8'h80 + iCol;
                    else           LCD_DATA <= 8'hC0 + iCol;
                    
                    LCD_EN <= 1'b1;
                    LCD_RS <= 1'b0;
                    state  <= SET_POS_HOLD;
                end

                SET_POS_HOLD: begin
                    LCD_EN <= 1'b0; // Chốt vị trí
                    state  <= SEND;
                end

                // Bước 4: Gửi dữ liệu hiển thị (Mã ASCII)
                SEND: begin
                    LCD_DATA <= iData;
                    LCD_EN   <= 1'b1;
                    LCD_RS   <= 1'b1; // RS=1 để ghi dữ liệu
                    state    <= SEND_HOLD;
                end

                SEND_HOLD: begin
                    LCD_EN <= 1'b0; // Chốt dữ liệu
                    state  <= IDLE; // Xong 1 ký tự, quay về chờ
                end

                default: state <= INIT;
            endcase
        end
    end
endmodule