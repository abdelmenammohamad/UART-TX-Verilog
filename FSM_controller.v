module FSM_controller (
    input reset,
    input vaild_in,
    input clk, 
    input PISO_finish,
    input enable_parity,
    output reg [2:0] mux_control,
    output  busy,
    output serial_enable,
    output reg parity_calc_reset
);

    reg en_parity;
    reg [2:0] current_state;
    reg [2:0] next_state;
    parameter IDLE = 0;
    parameter start_bit = 1;
    parameter PISO = 2;
    parameter parity_out = 3;
    parameter end_bit = 4;


    always @(posedge clk) begin
        if(!reset) begin
            current_state <= next_state; // Update state on valid input or state change
            if( (current_state== IDLE) && vaild_in) begin
                en_parity <= enable_parity; // Store the enable parity state
            end
            else en_parity <= en_parity; // Maintain the parity enable state  
        end else begin
            current_state <= IDLE; // Reset to IDLE state
            en_parity <= 0; // Reset parity enable state
        end          
    end

    always@(*) begin
        parity_calc_reset=1; // always 1 unles we use PISo

        case (current_state)
            IDLE: next_state = (vaild_in) ? start_bit : IDLE;
            start_bit: next_state = PISO;
            PISO: next_state = (PISO_finish) ? ( (en_parity) ? parity_out : end_bit ) : PISO;
            parity_out: next_state = end_bit;
            end_bit: next_state = IDLE;
            default: next_state = IDLE; 
        endcase
        

        case(current_state)
            //00 for IDLE state which is high, 01 for start bit, 10 for PISO output, 11 for end bit 
            IDLE: mux_control =  3'd0 ; // Idle state, no output,
            start_bit: mux_control = 3'd1; // Start bit
            PISO: 
            begin     
            	 parity_calc_reset=0;
           	 mux_control = 3'd2; // PISO output
            end 
            parity_out: mux_control = 3'd3;// parity output 
            end_bit: mux_control = 3'd4; // End bit
            default: mux_control = 3'd0; // Default case to avoid latches

        endcase 
    end

    assign busy = ( current_state==IDLE ) ? 1'b0 : 1'b1;
    assign serial_enable = ((current_state==IDLE) &&vaild_in ) ? 1'b1 : 1'b0; // Enable serial output when valid input, no problem if recieved the next data while sending the stop bit



endmodule // FSM_controller