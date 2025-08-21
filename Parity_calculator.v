
//parity_calculator 
// ODD parity meaning if 1 there is an odd number of 1's in the data_in
module Parity_calculator ( 
    input wire data_in,
    input wire clk,
    input wire reset,
    output reg parity_out
);

    always @(posedge clk) begin
        if (reset) begin
            parity_out <= 1'b0; // Reset parity output
        end else  parity_out <= parity_out ^ data_in; // XOR all bits for even parity
    end

endmodule // Parity_calculator