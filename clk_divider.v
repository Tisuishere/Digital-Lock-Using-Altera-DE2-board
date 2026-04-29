module clk_divider (
    input wire clk_in,    // Xung vào 50MHz
    output reg clk_out    // Xung ra 1kHz
);
    // Cần đếm 50,000 chu kỳ (50MHz / 1kHz)
    // Để tạo duty cycle 50%, ta đảo trạng thái sau mỗi 25,000 chu kỳ (0 đến 24999)
    reg [15:0] count = 0;
    
    always @(posedge clk_in) begin
        if (count == 2) begin
            count <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end
endmodule