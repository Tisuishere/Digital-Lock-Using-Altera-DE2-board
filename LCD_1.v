module LCD_1 (
    input               CLOCK_50,
    input  wire [0:0]   KEY,
    input  wire [2:0]   MODE,      // Trạng thái (Enter pass, Unlock,...)
    input  wire [15:0]  PASS_VAL,  // Dữ liệu 4 số từ bàn phím (mỗi số 4-bit)
    output reg  [7:0]   LCD_DATA,
    output wire         LCD_RW,
    output reg          LCD_EN,
    output reg          LCD_RS,
    output wire         LCD_ON
);

    // --- Signals ---
    wire reset = KEY[0];
    reg  clock;
    integer count;
    integer clockticks;
    
    localparam integer max  = 10; //50000
    localparam integer half = max / 2;
	
	 // --- State Definitions ---
    localparam INIT             = 4'd0;
    localparam INIT_MAINTAIN    = 4'd1;
    localparam HOME             = 4'd2;
    localparam HOME_MAINTAIN    = 4'd3;
    localparam WRDATA1          = 4'd4;
    localparam WRDATA1_MAINTAIN = 4'd5;
    localparam LINE2            = 4'd6;
    localparam LINE2_MAINTAIN   = 4'd7;
    localparam WRDATA2          = 4'd8;
    localparam WRDATA2_MAINTAIN = 4'd9;
    localparam DONE             = 4'd10;
	 
    reg [3:0]  state;
    reg [2:0]  mode_reg;
    reg [15:0] pass_reg; // Lưu giá trị pass cũ để phát hiện thay đổi

    // --- Clock Divider ---
    always @(posedge CLOCK_50) begin
        if (clockticks < max) clockticks <= clockticks + 1;
        else clockticks <= 0;
        clock <= (clockticks < half) ? 0 : 1;
    end 

    // --- Data Storage ---
    wire [7:0] initcode [0:7];
    reg  [7:0] line1    [0:15];
    reg  [7:0] line2    [0:15];

    assign initcode[0]=8'h38; assign initcode[1]=8'h38; assign initcode[2]=8'h38; assign initcode[3]=8'h38;
    assign initcode[4]=8'h08; assign initcode[5]=8'h01; assign initcode[6]=8'h06; assign initcode[7]=8'h0c;

    // --- Hàm chuyển đổi Hex sang ASCII ---
    // Nếu bạn muốn hiện số (1, 2, 3...) thì dùng mã 8'h30 + giá trị
    // Nếu bạn muốn hiện dấu "*" để bảo mật, hãy thay đổi logic ở đây
    function [7:0] to_ascii;
        input [3:0] hex_digit;
        begin
            case (hex_digit)
                4'h0: to_ascii = 8'h30; // '0'
                4'h1: to_ascii = 8'h31; // '1'
                4'h2: to_ascii = 8'h32;
                4'h3: to_ascii = 8'h33;
                4'h4: to_ascii = 8'h34;
                4'h5: to_ascii = 8'h35;
                4'h6: to_ascii = 8'h36;
                4'h7: to_ascii = 8'h37;
                4'h8: to_ascii = 8'h38;
                4'h9: to_ascii = 8'h39; // '9'
                4'hA: to_ascii = 8'h2A; // '*' (Hoặc 8'h41 cho 'A')
                default: to_ascii = 8'h20; // Khoảng trắng nếu chưa bấm
            endcase
        end
    endfunction

    // --- Logic cập nhật nội dung ---
    always @(*) begin
        // Dòng 1: Cập nhật theo MODE (giống như bài trước)
        case (MODE)
            3'd0: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "Enter pass      ";
            3'd1: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "Unlock          ";
            3'd2: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "Lock            ";
            3'd3: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "New pass        ";
            3'd4: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "Wrong!          ";
            3'd5: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "Correct!        ";
            default: {line1[0],line1[1],line1[2],line1[3],line1[4],line1[5],line1[6],line1[7],line1[8],line1[9],line1[10],line1[11],line1[12],line1[13],line1[14],line1[15]} = "System Ready    ";
        endcase

        // Dòng 2: "Pass in: XXXX"
        {line2[0],line2[1],line2[2],line2[3],line2[4],line2[5],line2[6],line2[7]} = "Pass in:";
        line2[8]  = 8'h20; // Khoảng trắng
        line2[9]  = to_ascii(PASS_VAL[15:12]); // Số thứ 1
        line2[10] = to_ascii(PASS_VAL[11:8]);  // Số thứ 2
        line2[11] = to_ascii(PASS_VAL[7:4]);   // Số thứ 3
        line2[12] = to_ascii(PASS_VAL[3:0]);   // Số thứ 4
        line2[13] = 8'h20; line2[14] = 8'h20; line2[15] = 8'h20;
    end
    
    assign LCD_ON = 1'b1;
    assign LCD_RW = 1'b0;

    // --- FSM Control ---
    always @(posedge clock or negedge reset) begin
        if (reset == 1'b0) begin
            count <= 0;
            state <= INIT;
            mode_reg <= 3'b111; // Giá trị ảo để ép refresh lần đầu
            pass_reg <= 16'hFFFF;
        end else begin
            // Refresh nếu MODE thay đổi HOẶC người dùng bấm phím mới (PASS_VAL thay đổi)
            if (MODE != mode_reg || PASS_VAL != pass_reg) begin
                mode_reg <= MODE;
                pass_reg <= PASS_VAL;
                state    <= HOME; 
            end else begin
                case (state)
                    INIT: begin
                        `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, initcode[count])
                        state <= INIT_MAINTAIN;
                    end
                    INIT_MAINTAIN: begin
                        LCD_EN <= 1'b0;
                        count  <= count + 1;
                        state  <= (count < 7) ? INIT : HOME;
                    end
                    HOME: begin
                        `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, 8'h80)
                        state <= HOME_MAINTAIN;
                    end
                    HOME_MAINTAIN: begin
                        LCD_EN <= 1'b0;
                        count  <= 0;
                        state  <= WRDATA1;
                    end
                    WRDATA1: begin
                        `WriteData(LCD_EN, LCD_RS, LCD_DATA, line1[count])
                        state <= WRDATA1_MAINTAIN;
                    end
                    WRDATA1_MAINTAIN: begin
                        LCD_EN <= 1'b0;
                        count  <= count + 1;
                        state  <= (count < 15) ? WRDATA1 : LINE2;
                    end
                    LINE2: begin
                        `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, 8'hC0)
                        state <= LINE2_MAINTAIN;
                    end
                    LINE2_MAINTAIN: begin
                        LCD_EN <= 1'b0;
                        count  <= 0;
                        state  <= WRDATA2;
                    end
                    WRDATA2: begin
                        `WriteData(LCD_EN, LCD_RS, LCD_DATA, line2[count])
                        state <= WRDATA2_MAINTAIN;
                    end
                    WRDATA2_MAINTAIN: begin
                        LCD_EN <= 1'b0;
                        count  <= count + 1;
                        state  <= (count < 15) ? WRDATA2 : DONE;
                    end
                    DONE: state <= DONE;
                    default: state <= DONE;
                endcase
            end
        end
    end
endmodule