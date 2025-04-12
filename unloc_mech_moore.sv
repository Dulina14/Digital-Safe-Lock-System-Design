module unloc_mech_moore #(parameter N = 4) (
    input logic clk, rstn, ser_val, ser_data,
    output logic output_val, output_data, ser_ready
);
    // State encoding
    typedef enum logic [2:0] {
        IDLE,       // Idle state
        STATE_A,    // Received '1'
        STATE_B,    // Received '10'
        STATE_C,    // Received '101'
        STATE_D,    // Received '1011' (correct)
        INCORRECT   // Incorrect sequence
    } state_t;
    
    state_t state, next_state;
    logic [$clog2(N)-1:0] bit_number;

    // Next state logic (combinational)
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (ser_val && ser_ready) begin
                    next_state = (ser_data == 1) ? STATE_A : INCORRECT;
                end
            end
            
            STATE_A: begin
                if (ser_val && ser_ready) begin
                    next_state = (ser_data == 0) ? STATE_B : INCORRECT;
                end
            end
            
            STATE_B: begin
                if (ser_val && ser_ready) begin
                    next_state = (ser_data == 1) ? STATE_C : INCORRECT;
                end
            end
            
            STATE_C: begin
                if (ser_val && ser_ready) begin
                    next_state = (ser_data == 1) ? STATE_D : INCORRECT;
                end
            end
            
            STATE_D: begin
                next_state = IDLE; // Return to IDLE after outputting result
            end
            
            INCORRECT: begin
                next_state = IDLE; // Return to IDLE after outputting result
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // State register and bit counter (sequential)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            bit_number <= 0;
        end
        else begin
            state <= next_state;
            // Increment bit_number on valid bit, reset in IDLE
            if (next_state == IDLE)
                bit_number <= 0;
            else if (ser_val && ser_ready && state != IDLE)
                bit_number <= bit_number + 1;
        end
    end
    
    // Moore output logic - depends only on state
    always_comb begin
        output_val = 0;
        output_data = 0;
        ser_ready = 1;
        
        case (state)
            IDLE, STATE_A, STATE_B: begin
                output_val = 0;
                output_data = 0;
                ser_ready = 1;
            end
            
            STATE_C: begin
                output_val = (bit_number == N-1); // Output valid on 4th bit
                output_data = (ser_data == 1 && ser_val && ser_ready); // Correct if last bit is 1
                ser_ready = 1;
            end
            
            STATE_D: begin
                output_val = 1;
                output_data = 1; // Correct sequence
                ser_ready = 1;
            end
            
            INCORRECT: begin
                output_val = 1;
                output_data = 0; // Incorrect sequence
                ser_ready = 1;
            end
            
            default: begin
                output_val = 0;
                output_data = 0;
                ser_ready = 1;
            end
        endcase
    end
    
endmodule