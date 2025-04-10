module unloc_mech_moore(
    input logic clk, rstn, ser_val, ser_data,
    output logic output_val, output_data
);

    typedef enum logic [2:0] {
        IDLE,       // Idle state
        STATE_A,    // State A 
        STATE_B,    // State B
        STATE_C,    // State C 
        STATE_D,    // State D
        INCORRECT   // Incorrect state
    } state_t;
    
    state_t state, next_state;
    
    // Next state logic (combinational)
    always_comb begin
        next_state = state;
        
        case(state)
            IDLE: begin
                if (ser_val == 0)
                    next_state = IDLE;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = STATE_A;
                else if (ser_val == 1 && ser_data == 0)
                    next_state = INCORRECT;
            end
            
            STATE_A: begin
                if (ser_val == 0)
                    next_state = STATE_A;
                else if (ser_val == 1 && ser_data == 0)
                    next_state = STATE_B;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = INCORRECT;
            end
            
            STATE_B: begin
                if (ser_val == 0)
                    next_state = STATE_B;
                else if (ser_val == 1 && ser_data == 0)
                    next_state = INCORRECT;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = STATE_C;
            end
            
            STATE_C: begin
                if (ser_val == 0)
                    next_state = STATE_C;
                else if (ser_val == 1 && ser_data == 0)
                    next_state = INCORRECT;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = STATE_D;
            end
            
            STATE_D: begin
                if (ser_val == 0)
                    next_state = STATE_D;
                else if (ser_val == 1 && ser_data == 0 || ser_val == 1 && ser_data == 1)
                    next_state = IDLE;
            end
            
            INCORRECT: begin
                if (ser_val == 0)
                    next_state = INCORRECT;
                else if (ser_val == 1 && ser_data == 0 || ser_val == 1 && ser_data == 1)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // State register (sequential)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // Moore output logic - depends only on current state
    always_comb begin
        case(state)
            IDLE: begin
                output_val = 0;
                output_data = 0;
            end
            
            STATE_A: begin
                output_val = 1;
                output_data = 0;
            end
            
            STATE_B: begin
                output_val = 1;
                output_data = 0;
            end
            
            STATE_C: begin
                output_val = 1;
                output_data = 0;
            end
            
            STATE_D: begin
                output_val = 1;
                output_data = 1;
            end
            
            INCORRECT: begin
                output_val = 1;
                output_data = 0;
            end
            
            default: begin
                output_val = 0;
                output_data = 0;
            end
        endcase
    end
    
endmodule