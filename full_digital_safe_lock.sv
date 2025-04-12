module full_digital_safe_lock #(
    parameter N = 4
)
(
    input logic clk,rstn,
    input logic par_valid,
    input logic [N-1 : 0] par_data,
    output logic output_val, output_data
);

    logic par_ready, ser_val, ser_ready, ser_data

    p2s #(.N(N)
    ) P2S(
        .clk(clk),
        .rstn(rstn),
        .par_ready(par_ready),
        .par_valid(par_valid),
        .par_data(par_data),
        .ser_val(ser_val),
        .ser_ready(ser_ready),
        .ser_data(ser_data)
    );

    unloc_mech_moore UMM(
        .clk(clk),
        .rstn(rstn),
        .ser_val(ser_val),
        .ser_ready(ser_ready),
        .ser_data(ser_data),
        .output_data(output_data),
        .output_val(output_val)
    );

endmodule