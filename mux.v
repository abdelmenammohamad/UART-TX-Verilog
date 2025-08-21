

module MUX (
    input wire  start_bit,
    input wire  end_bit,
    input wire  serial_out_bit,
    input wire  parity_bit,
    input wire [2:0] select,
    output reg  TX_out
);

    always @(*) begin
        case(select)
            3'b000: TX_out = 1'b1; // Default case, idle state
            3'd1: TX_out = start_bit;
            3'd2: TX_out = serial_out_bit;
            3'd3: TX_out = parity_bit;
            3'd4: TX_out = end_bit;
            default: TX_out = 1'b1; // default is one due to idle case of UART being one.
        endcase
    end


endmodule // MUX