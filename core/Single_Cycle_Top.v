`include "P_c.v"
`include "Instruction_Memory.v"
`include "Register_files.v"
`include "Sign_Extend.v"
`include "ALU.v"
`include "Control_Unit_Top.v"
`include "Data_Mem.v"
`include "PC_Adder.v"

module Single_Cycle_Top (clk, rst);

input clk, rst;

// Wires
wire [31:0] PC_Top, RD_Instr, Imm_Ext_Top;
wire [31:0] ALUResult, ReadData, PCPlus4;
wire [31:0] RD1_Top, RD2_Top;

wire [2:0] ALUControl_Top;

wire RegWrite, ALUSrc, MemWrite, ResultSrc, Branch;

wire Zero, N, V, C;

// ---------------- PC ----------------
P_C PC(
    .clk(clk),
    .rst(rst),
    .PC(PC_Top),
    .PC_NEXT(PCPlus4)
);

// ---------------- Instruction Memory ----------------
Instr_Mem Instruction_Memory(
    .rst(rst),
    .A(PC_Top),
    .RD(RD_Instr)
);

// ---------------- Register File ----------------
Reg_file Register_File(
    .clk(clk),
    .rst(rst),
    .WE3(RegWrite),
    .WD3(ResultSrc ? ReadData : ALUResult),
    .A1(RD_Instr[19:15]),
    .A2(RD_Instr[24:20]),
    .A3(RD_Instr[11:7]),
    .RD1(RD1_Top),
    .RD2(RD2_Top)
);

// ---------------- Immediate Generator ----------------
Sign_Extend Sign_Extend(
    .In(RD_Instr),
    .Imm_Ext(Imm_Ext_Top)
);

// ---------------- ALU ----------------
alu ALU(
    .A(RD1_Top),
    .B(ALUSrc ? Imm_Ext_Top : RD2_Top),
    .ALUControl(ALUControl_Top),
    .Result(ALUResult),
    .Z(Zero),
    .N(N), 
    .V(V), 
    .C(C)
);

// ---------------- Control Unit ----------------
Control_Unit_Top CU(
    .Op(RD_Instr[6:0]),
    .funct3(RD_Instr[14:12]),
    .funct7(RD_Instr[30]),
    .RegWrite(RegWrite),
    .ImmSrc(),
    .ALUSrc(ALUSrc),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .Branch(Branch),
    .ALUControl(ALUControl_Top)
);

// ---------------- Data Memory ----------------
Data_Memory DM(
    .A(ALUResult),
    .WD3(RD2_Top),
    .clk(clk),
    .WE(MemWrite),
    .RD(ReadData)
);

// ---------------- PC Adder ----------------
PC_Adder PC_Adder(
    .a(PC_Top),
    .b(32'd4),
    .c(PCPlus4)
);

endmodule