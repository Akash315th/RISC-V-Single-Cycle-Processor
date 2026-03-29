module Instr_Mem(A, rst, RD);

input [31:0] A;
input rst;

output [31:0] RD;

reg [31:0] Mem [1023:0];

assign RD = (rst == 1'b0) ? 32'h00000000 : Mem[A[31:2]];

// Optional: Initialize memory
initial begin
    // Example instructions (you can replace)
    Mem[0] = 32'hFFC4A303; 
    //Mem[1] = 32'h00100093; // ADDI x1, x0, 1
    //Mem[2] = 32'h00200113; // ADDI x2, x0, 2
end

endmodule