module UART_TX (
    input wire clk,
    input wire reset,
    input wire vaild_in, // Trigger to start transmission
    input wire [7:0] tx_data_8bit, // Parallel input data
    input wire enable_parity, // Enable odd parity
    output wire TX_out, // Final UART output
    output wire busy // Indicates UART is busy transmitting
);

    // Internal signals
    wire serial_out_bit;
    wire start_bit = 1'b0; // Start bit is always 0 in UART
    wire end_bit = 1'b1;   // Stop bit is always 1 in UART
    wire parity_out;
    wire parity_reset;
    wire serial_enable;
    wire PISO_finish;
    wire [2:0] mux_select;

    // Parity calculator instance
    Parity_calculator parity_unit (
        .data_in(serial_out_bit),
        .clk(clk),
        .reset(parity_reset),
        .parity_out(parity_out)
    );

    // PISO (Parallel In Serial Out) shift register
    PISO piso_unit (
        .reset(reset),
        .clk(clk),
        .en_serial(serial_enable),
        .parallel_in(tx_data_8bit),
        .serial_out(serial_out_bit),
        .finish(PISO_finish)
    );

    // FSM controller
    FSM_controller fsm_unit (
        .reset(reset),
        .vaild_in(vaild_in),
        .clk(clk),
        .PISO_finish(PISO_finish),
        .enable_parity(enable_parity),
        .mux_control(mux_select),
        .busy(busy),
        .serial_enable(serial_enable),
        .parity_calc_reset(parity_reset)
    );

    // Output MUX to select between start, serial, parity, and end bits
    MUX mux_unit (
        .start_bit(start_bit),
        .end_bit(end_bit),
        .serial_out_bit(serial_out_bit),
        .parity_bit(parity_out),
        .select(mux_select),
        .TX_out(TX_out)
    );

endmodule