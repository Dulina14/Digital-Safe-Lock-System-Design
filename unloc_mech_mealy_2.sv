module unloc_mech_mealy(
    input  logic clk, rstn,
    input  logic ser_val, ser_data,
    output logic output_data, output_val,
    output logic output_data_comb, output_val_comb  
);

    typedef enum logic [1:0]{
        IDLE,       // Idle state
        STATE_A,    // State A
        STATE_B,    // State B
        STATE_C     // State C
    } state_t;
    
    state_t state, next_state;
    
    // Next state logic (combinational)
    always_comb begin
        next_state = state;
        case(state)
            IDLE: begin
                if (ser_val == 0 || ser_data == 0)
                    next_state = IDLE;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = STATE_A;
            end
            
            STATE_A: begin
                if (ser_val == 0)
                    next_state = STATE_A;
                else if (ser_val == 1 && ser_data == 0)
                    next_state = STATE_B;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = IDLE;
            end
            
            STATE_B: begin
                if (ser_val == 0)
                    next_state = STATE_B;
                else if (ser_val == 1 && ser_data == 0)
                    next_state = IDLE;
                else if (ser_val == 1 && ser_data == 1)
                    next_state = STATE_C;
            end
            
            STATE_C: begin
                if (ser_val == 0)
                    next_state = STATE_C;
                else // ser_val == 1 (any ser_data value)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // State Register (Sequential)
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // Mealy output logic - combinational outputs
    always_comb begin

        output_data_comb = 0;
        output_val_comb = 0;
        
        case (state)
            IDLE: begin
                if (ser_val == 0) begin
                    output_val_comb = 0;
                    output_data_comb = 0;
                end else if (ser_val == 1 && ser_data == 0) begin
                    output_val_comb = 1;
                    output_data_comb = 0;
                end else if (ser_val == 1 && ser_data == 1) begin
                    output_val_comb = 0;
                    output_data_comb = 0;
                end
            end
            
            STATE_A: begin
                if (ser_val == 0 || (ser_val == 1 && ser_data == 0)) begin
                    output_val_comb = 0;
                    output_data_comb = 0;
                end else if (ser_val == 1 && ser_data == 1) begin
                    output_val_comb = 0;
                    output_data_comb = 0;
                end
            end
            
            STATE_B: begin
                if (ser_val == 0 || (ser_val == 1 && ser_data == 1)) begin
                    output_val_comb = 0;
                    output_data_comb = 0;
                end else if (ser_val == 1 && ser_data == 0) begin
                    output_val_comb = 1;
                    output_data_comb = 0;
                end
            end
            
            STATE_C: begin
                if (ser_val == 0) begin
                    output_val_comb = 0;
                    output_data_comb = 0;
                end else if (ser_val == 1 && ser_data == 0) begin
                    output_val_comb = 1;
                    output_data_comb = 0;
                end else if (ser_val == 1 && ser_data == 1) begin
                    output_val_comb = 1;
                    output_data_comb = 1;
                end
            end
            
            default: begin
                output_val_comb = 0;
                output_data_comb = 0;
            end
        endcase
    end

    // Registered outputs
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            output_data <= 0;
            output_val <= 0;
        end else begin
            output_data <= output_data_comb;
            output_val <= output_val_comb;
        end
    end
   
endmodule