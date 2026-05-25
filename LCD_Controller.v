module LCD_Controller(
    input            CLOCK_50,
    input            reset_n,
    input            iValid,   
    input  [0:0]     iRow,     
    input  [3:0]     iCol,     
    input  [7:0]     iData,    
    output reg       oReady,   
    output reg [7:0] LCD_DATA,
    output wire      LCD_RW,
    output reg       LCD_EN,
    output reg       LCD_RS,
    output wire      LCD_ON
);

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

    always @(posedge clk_1k or negedge reset_n) begin
        if (!reset_n) begin
            state  <= INIT;
            count  <= 0;
            oReady <= 1'b0;
            LCD_EN <= 1'b0;
        end else begin
            case (state)
                INIT: begin
                    case (count)
                        4'd0: LCD_DATA <= 8'h38;
                        4'd1: LCD_DATA <= 8'h38;
                        4'd2: LCD_DATA <= 8'h38;
                        4'd3: LCD_DATA <= 8'h38;
                        4'd4: LCD_DATA <= 8'h08; 
                        4'd5: LCD_DATA <= 8'h01; 
                        4'd6: LCD_DATA <= 8'h06; 
                        4'd7: LCD_DATA <= 8'h0C; 
                        default: LCD_DATA <= 8'h00;
                    endcase
                    LCD_EN <= 1'b1;
                    LCD_RS <= 1'b0;
                    state  <= INIT_HOLD;
                end

                INIT_HOLD: begin
                    LCD_EN <= 1'b0; 
                    if (count < 7) begin
                        count <= count + 1;
                        state <= INIT;
                    end else begin
                        state <= IDLE;
                    end
                end

                IDLE: begin
                    oReady <= 1'b1; 
                    if (iValid) begin
                        oReady <= 1'b0; 
                        state  <= SET_POS;
                    end
                end

                SET_POS: begin
                    if (iRow == 0) LCD_DATA <= 8'h80 + iCol;
                    else           LCD_DATA <= 8'hC0 + iCol;
                    
                    LCD_EN <= 1'b1;
                    LCD_RS <= 1'b0;
                    state  <= SET_POS_HOLD;
                end

                SET_POS_HOLD: begin
                    LCD_EN <= 1'b0; 
                    state  <= SEND;
                end

                SEND: begin
                    LCD_DATA <= iData;
                    LCD_EN   <= 1'b1;
                    LCD_RS   <= 1'b1; 
                    state    <= SEND_HOLD;
                end

                SEND_HOLD: begin
                    LCD_EN <= 1'b0; 
                    state  <= IDLE; 
                end

                default: state <= INIT;
            endcase
        end
    end
endmodule