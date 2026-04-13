/////////////////////////////////////////////////////////////////
// Author:    Duong Computing (YouTube.com/DuongComputing)      //
// Email:     duong.uitce@gmail.com                             //
// Website:   https://sites.google.com/view/duongcomputing     //
// File:      LCD.v                                             //
// Function:  Controlling LCD 16x2 on Altera DE2/DE2-115 Board  //
// Date:      Nov 11, 2024                                      //
/////////////////////////////////////////////////////////////////
// Dòng 1: Enter pass, Unlock, Lock, New pass, Wrong, Correct
// Dòng 2: Pass in
// --- MACROS ---
`define WriteInstruction(ctr_en, ctr_rs, data, source) \
    data   <= source; \
    ctr_en <= 1'b1;   \
    ctr_rs <= 1'b0;

`define WriteData(ctr_en, ctr_rs, data, source) \
    data   <= source; \
    ctr_en <= 1'b1;   \
    ctr_rs <= 1'b1;

module LCD (
    input            CLOCK_50,
    input  wire [0:0] KEY,
    output reg  [7:0] LCD_DATA,
    output wire       LCD_RW,
    output reg        LCD_EN,
    output reg        LCD_RS,
    output wire       LCD_ON
);

    // --- Signals ---
    wire reset = KEY[0];
    reg  clock;
    
    integer count;
    integer clockticks;
    
    localparam integer max  = 4; //50000
    localparam integer half = max / 2;

    // --- State Machine Parameters ---
    localparam [3:0] INIT             = 4'd0,  // Khởi tạo (8 chu kỳ)
                     INIT_MAINTAIN    = 4'd1,
                     HOME             = 4'd2,  // Về đầu dòng 1
                     HOME_MAINTAIN    = 4'd3,
                     WRDATA1          = 4'd4,  // Ghi dòng 1 (16 ký tự)
                     WRDATA1_MAINTAIN = 4'd5,
                     LINE2            = 4'd6,  // Nhảy xuống dòng 2
                     LINE2_MAINTAIN   = 4'd7,
                     WRDATA2          = 4'd8,  // Ghi dòng 2 (16 ký tự)
                     WRDATA2_MAINTAIN = 4'd9,
                     DONE             = 4'd10;

    reg [3:0] state;

    // --- Clock Divider (50MHz -> 1kHz) ---
    always @(posedge CLOCK_50) begin
        if (clockticks < max)
            clockticks <= clockticks + 1;
        else
            clockticks <= 0;

        if (clockticks < half)
            clock <= 0;
        else
            clock <= 1;
    end 

    // --- ROM Data (LCD Codes & Characters) ---
    wire [7:0] initcode [0:7];
    wire [7:0] line1    [0:15];
    wire [7:0] line2    [0:15];

    // Khởi tạo LCD theo datasheet HD44780
    assign initcode[0] = 8'h38; // 8-bit, 2 lines, 5x8 font
    assign initcode[1] = 8'h38;
    assign initcode[2] = 8'h38;
    assign initcode[3] = 8'h38; 
    assign initcode[4] = 8'h08; // Display off
    assign initcode[5] = 8'h01; // Clear display
    assign initcode[6] = 8'h06; // Entry mode: Increment
    assign initcode[7] = 8'h0c; // Display on, cursor off

    // Nội dung dòng 1: "    Welcome     "
    assign line1[0]  = 8'h20; assign line1[1]  = 8'h20;
    assign line1[2]  = 8'h20; assign line1[3]  = 8'h20;
    assign line1[4]  = 8'h57; // W
    assign line1[5]  = 8'h65; // e
    assign line1[6]  = 8'h6C; // l
    assign line1[7]  = 8'h63; // c
    assign line1[8]  = 8'h6F; // o
    assign line1[9]  = 8'h6D; // m
    assign line1[10] = 8'h65; // e
    assign line1[11] = 8'h20; assign line1[12] = 8'h20;
    assign line1[13] = 8'h20; assign line1[14] = 8'h20;
    assign line1[15] = 8'h20;

    // Nội dung dòng 2: "   To ESD Lab   "
    assign line2[0]  = 8'h20; assign line2[1]  = 8'h20;
    assign line2[2]  = 8'h20;
    assign line2[3]  = 8'h54; // T
    assign line2[4]  = 8'h6F; // o
    assign line2[5]  = 8'h20;   
    assign line2[6]  = 8'h45; // E
    assign line2[7]  = 8'h53; // S
    assign line2[8]  = 8'h44; // D
    assign line2[9]  = 8'h20;
    assign line2[10] = 8'h4C; // L
    assign line2[11] = 8'h61; // a
    assign line2[12] = 8'h62; // b
    assign line2[13] = 8'h20; assign line2[14] = 8'h20;
    assign line2[15] = 8'h20;
    
    assign LCD_ON = 1'b1;
    assign LCD_RW = 1'b0; // Luôn ở chế độ ghi

    // --- Main Control FSM ---
    always @(posedge clock or negedge reset) begin
        if (reset == 1'b0) begin
            count <= 0;
            state <= INIT;
            LCD_EN <= 1'b0;
        end else begin
            case (state)
                // Giai đoạn khởi tạo
                INIT: begin
                    `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, initcode[count])
                    state <= INIT_MAINTAIN;
                end
                     
                INIT_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count  <= count + 1;
                    state  <= (count < 7) ? INIT : HOME;
                end
                     
                // Cài đặt vị trí dòng 1
                HOME: begin
                    `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, 8'h80) // Địa chỉ 0x00
                    state <= HOME_MAINTAIN;
                end
                     
                HOME_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count  <= 0;
                    state  <= WRDATA1;
                end
                     
                // Ghi dữ liệu dòng 1
                WRDATA1: begin
                    `WriteData(LCD_EN, LCD_RS, LCD_DATA, line1[count])
                    state <= WRDATA1_MAINTAIN;
                end
                     
                WRDATA1_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count  <= count + 1;
                    state  <= (count < 15) ? WRDATA1 : LINE2;
                end
                     
                // Chuyển sang dòng 2
                LINE2: begin
                    `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, 8'hC0) // Địa chỉ 0x40
                    state <= LINE2_MAINTAIN;
                end
                     
                LINE2_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count  <= 0;
                    state  <= WRDATA2;
                end
                     
                // Ghi dữ liệu dòng 2
                WRDATA2: begin
                    `WriteData(LCD_EN, LCD_RS, LCD_DATA, line2[count])
                    state <= WRDATA2_MAINTAIN;
                end
                     
                WRDATA2_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count  <= count + 1;
                    state  <= (count < 15) ? WRDATA2 : DONE;
                end
                     
                // Hoàn tất
                DONE: begin
                    state <= DONE;
                end
                
                default: state <= DONE;
            endcase
        end
    end

endmodule