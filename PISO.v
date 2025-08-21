module PISO
(
    input wire reset,
    input clk,
    input en_serial,
    input [7:0] parallel_in,
    output reg serial_out,
    output reg finish
    
);

reg [7:0] shift_register;
reg [3:0] bit_count;
reg busy_PISO;


//expected parallel_in at the same clock of en_serial
always @(posedge clk)begin
    if(reset) begin
        finish <= 0;
        busy_PISO <= 0;
        serial_out <= 1'b1; // default value is one when not busy
        bit_count <= 4'b0; // Reset bit count when not busy
        shift_register <= 8'b0; // Reset shift register when not busy
    end
    else begin
        if(en_serial && ~busy_PISO)begin
            shift_register <= parallel_in;
            bit_count <= 4'b0;
            busy_PISO<=1'b1;
            finish <=1'b0;
            serial_out <= 1'b1; // defalut value is one
        end
        else if(busy_PISO) begin//if en_serial while busy we still continue
            serial_out <= shift_register[0];
            shift_register <= shift_register >> 1;
            bit_count <= bit_count + 1;

            if(bit_count == 4'b0111)begin
                finish <= 1;
                busy_PISO<=0;
            end
            else begin
                finish <= 0;
                busy_PISO <= 1;
            end
        end
        else begin
            finish <= 0;
            busy_PISO <= 0;
            serial_out <= 1'b1; // default value is one when not busy
            bit_count <= 4'b0; // Reset bit count when not busy
            shift_register <= 8'b0; // Reset shift register when not busy
        end
    end
end


endmodule