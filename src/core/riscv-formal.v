`include "src/defs.v"

`define NRET 2
`define BICANTOR_RVFI_IO                             \
,output wire [`NRET      - 1:0]  rvfi_valid          \
,output wire [`NRET * 64 - 1:0]  rvfi_order          \
,output wire [`NRET * 32 - 1:0]  rvfi_insn           \
,output wire [`NRET      - 1:0]  rvfi_trap           \
,output reg  [`NRET      - 1:0]  rvfi_halt      = 0  \
,output reg  [`NRET      - 1:0]  rvfi_intr      = 0  \
,output reg  [`NRET *  2 - 1:0]  rvfi_mode      = 15 \
,output reg  [`NRET *  2 - 1:0]  rvfi_ixl       = 0  \
,output wire [`NRET *  5 - 1:0]  rvfi_rs1_addr       \
,output wire [`NRET *  5 - 1:0]  rvfi_rs2_addr       \
,output wire [`NRET * 32 - 1:0]  rvfi_rs1_rdata      \
,output wire [`NRET * 32 - 1:0]  rvfi_rs2_rdata      \
,output wire [`NRET *  5 - 1:0]  rvfi_rd_addr        \
,output wire [`NRET * 32 - 1:0]  rvfi_rd_wdata       \
,output wire [`NRET * 32 - 1:0]  rvfi_pc_rdata       \
,output wire [`NRET * 32 - 1:0]  rvfi_pc_wdata       \
,output reg  [`NRET * 32 - 1:0]  rvfi_mem_addr  = 0  \
,output reg  [`NRET *  4 - 1:0]  rvfi_mem_rmask = 0  \
,output reg  [`NRET *  4 - 1:0]  rvfi_mem_wmask = 0  \
,output reg  [`NRET * 32 - 1:0]  rvfi_mem_rdata = 0  \
,output reg  [`NRET * 32 - 1:0]  rvfi_mem_wdata = 0

// Splitting channels into two sets of wires for easier comparison to spec
`define BICANTOR_RVFI_CH0_WIRES                                                         \
wire [ 1 - 1:0]  rvfi_ch0_valid     = (ctrl0_wb_iw != 0) && !trap0_wb_ow;               \
wire [64 - 1:0]  rvfi_ch0_order     = rvfi_wb_0[`RVFI_ORDER];                           \
wire [32 - 1:0]  rvfi_ch0_insn      = rvfi_wb_0[`RVFI_INSN];                            \
wire [ 1 - 1:0]  rvfi_ch0_trap      = trap0_wb_ow;                                      \
reg  [ 1 - 1:0]  rvfi_ch0_halt      = 0;                                                \
reg  [ 1 - 1:0]  rvfi_ch0_intr      = 0;                                                \
reg  [ 2 - 1:0]  rvfi_ch0_mode      = 0;                                                \
reg  [ 2 - 1:0]  rvfi_ch0_ixl       = 0;                                                \
wire [ 5 - 1:0]  rvfi_ch0_rs1_addr  = rvfi_wb_0[`RVFI_RS1_ADDR];                        \
wire [ 5 - 1:0]  rvfi_ch0_rs2_addr  = ( ctrl0_wb_iw[`ALU_SRC2_MUX] == `RS2_SEL ) ? rvfi_wb_0[`RVFI_RS2_ADDR] : 0; \
wire [32 - 1:0]  rvfi_ch0_rs1_rdata = ( (ctrl0_wb_iw[`ALU_SRC1_MUX] == `RS1_SEL) && (rvfi_wb_0[`RVFI_RS1_ADDR] != 0) ) ? rvfi_wb_0[`RVFI_RS1_DATA] : 0; \
wire [32 - 1:0]  rvfi_ch0_rs2_rdata = ( (ctrl0_wb_iw[`ALU_SRC2_MUX] == `RS2_SEL) && (rvfi_wb_0[`RVFI_RS2_ADDR] != 0) ) ? rvfi_wb_0[`RVFI_RS2_DATA] : 0; \
wire [ 5 - 1:0]  rvfi_ch0_rd_addr   = ctrl0_wb_iw[`REGWRITE] ? rd_addr_0_wb_iw : 0;     \
wire [32 - 1:0]  rvfi_ch0_rd_wdata  = (  rd_addr_0_wb_iw != 5'b0 ) ? rd_data0_wb_ow : 0;\
wire [32 - 1:0]  rvfi_ch0_pc_rdata  = rvfi_wb_0[`RVFI_PC_RDATA];                        \
wire [32 - 1:0]  rvfi_ch0_pc_wdata  = rvfi_wb_0[`RVFI_PC_WDATA];                        \
reg  [32 - 1:0]  rvfi_ch0_mem_addr  = 0;                                                \
reg  [ 4 - 1:0]  rvfi_ch0_mem_rmask = 0;                                                \
reg  [ 4 - 1:0]  rvfi_ch0_mem_wmask = 0;                                                \
reg  [32 - 1:0]  rvfi_ch0_mem_rdata = 0;                                                \
reg  [32 - 1:0]  rvfi_ch0_mem_wdata = 0;

`define BICANTOR_RVFI_CH1_WIRES                                                         \
wire [ 1 - 1:0]  rvfi_ch1_valid     = (ctrl1_wb_iw != 0) && !trap_1_wb_ow;              \
wire [64 - 1:0]  rvfi_ch1_order     = rvfi_wb_1[`RVFI_ORDER];                           \
wire [32 - 1:0]  rvfi_ch1_insn      = rvfi_wb_1[`RVFI_INSN];                            \
wire [ 1 - 1:0]  rvfi_ch1_trap      = trap1_wb_ow;                                      \
reg  [ 1 - 1:0]  rvfi_ch1_halt      = 0;                                                \
reg  [ 1 - 1:0]  rvfi_ch1_intr      = 0;                                                \
reg  [ 2 - 1:0]  rvfi_ch1_mode      = 0;                                                \
reg  [ 2 - 1:0]  rvfi_ch1_ixl       = 0;                                                \
wire [ 5 - 1:0]  rvfi_ch1_rs1_addr  = rvfi_wb_1[`RVFI_RS1_ADDR];                        \
wire [ 5 - 1:0]  rvfi_ch1_rs2_addr  = ( ctrl1_wb_iw[`ALU_SRC2_MUX] == `RS2_SEL ) ? rvfi_wb_1[`RVFI_RS2_ADDR] : 0; \
wire [32 - 1:0]  rvfi_ch1_rs1_rdata = ( (ctrl1_wb_iw[`ALU_SRC1_MUX] == `RS1_SEL) && (rvfi_wb_1[`RVFI_RS1_ADDR] != 0) ) ? rvfi_wb_1[`RVFI_RS1_DATA] : 0; \
wire [32 - 1:0]  rvfi_ch1_rs2_rdata = ( (ctrl1_wb_iw[`ALU_SRC2_MUX] == `RS2_SEL) && (rvfi_wb_1[`RVFI_RS1_ADDR] != 0) ) ? rvfi_wb_1[`RVFI_RS2_DATA] : 0; \
wire [ 5 - 1:0]  rvfi_ch1_rd_addr   = ctrl1_wb_iw[`REGWRITE] ? rd_addr_1_wb_iw : 0;     \
wire [32 - 1:0]  rvfi_ch1_rd_wdata  = (  rd_addr_1_wb_iw != 5'b0 ) ? rd_data1_wb_ow : 0;\
wire [32 - 1:0]  rvfi_ch1_pc_rdata  = rvfi_wb_1[`RVFI_PC_RDATA];                        \
wire [32 - 1:0]  rvfi_ch1_pc_wdata  = rvfi_wb_1[`RVFI_PC_WDATA];                        \
reg  [32 - 1:0]  rvfi_ch1_mem_addr  = 0;                                                \
reg  [ 4 - 1:0]  rvfi_ch1_mem_rmask = 0;                                                \
reg  [ 4 - 1:0]  rvfi_ch1_mem_wmask = 0;                                                \
reg  [32 - 1:0]  rvfi_ch1_mem_rdata = 0;                                                \
reg  [32 - 1:0]  rvfi_ch1_mem_wdata = 0;

`define BICANTOR_CONNECT_WIRES                                                          \
assign rvfi_valid    [`CHAN(1 ,0)]   = rvfi_ch0_valid;                                  \
assign rvfi_order    [`CHAN(64,0)]   = rvfi_ch0_order;                                  \
assign rvfi_insn     [`CHAN(32,0)]   = rvfi_ch0_insn;                                   \
assign rvfi_trap     [`CHAN(1 ,0)]   = rvfi_ch0_trap;                                   \
assign rvfi_rs1_addr [`CHAN(5 ,0)]   = rvfi_ch0_rs1_addr;                               \
assign rvfi_rs2_addr [`CHAN(5 ,0)]   = rvfi_ch0_rs2_addr;                               \
assign rvfi_rs1_rdata[`CHAN(32,0)]   = rvfi_ch0_rs1_rdata;                              \
assign rvfi_rs2_rdata[`CHAN(32,0)]   = rvfi_ch0_rs2_rdata;                              \
assign rvfi_rd_addr  [`CHAN(5 ,0)]   = rvfi_ch0_rd_addr;                                \
assign rvfi_rd_wdata [`CHAN(32,0)]   = rvfi_ch0_rd_wdata;                               \
assign rvfi_pc_rdata [`CHAN(32,0)]   = rvfi_ch0_pc_rdata;                               \
assign rvfi_pc_wdata [`CHAN(32,0)]   = rvfi_ch0_pc_wdata;                               \
                                                                                        \
assign rvfi_valid    [`CHAN(1 ,1)]   = rvfi_ch1_valid;                                  \
assign rvfi_order    [`CHAN(64,1)]   = rvfi_ch1_order;                                  \
assign rvfi_insn     [`CHAN(32,1)]   = rvfi_ch1_insn;                                   \
assign rvfi_trap     [`CHAN(1 ,1)]   = rvfi_ch1_trap;                                   \
assign rvfi_rs1_addr [`CHAN(5 ,1)]   = rvfi_ch1_rs1_addr;                               \
assign rvfi_rs2_addr [`CHAN(5 ,1)]   = rvfi_ch1_rs2_addr;                               \
assign rvfi_rs1_rdata[`CHAN(32,1)]   = rvfi_ch1_rs1_rdata;                              \
assign rvfi_rs2_rdata[`CHAN(32,1)]   = rvfi_ch1_rs2_rdata;                              \
assign rvfi_rd_addr  [`CHAN(5 ,1)]   = rvfi_ch1_rd_addr;                                \
assign rvfi_rd_wdata [`CHAN(32,1)]   = rvfi_ch1_rd_wdata;                               \
assign rvfi_pc_rdata [`CHAN(32,1)]   = rvfi_ch1_pc_rdata;                               \
assign rvfi_pc_wdata [`CHAN(32,1)]   = rvfi_ch1_pc_wdata;

`define BICANTOR_RVFI_DRIVER        \
`BICANTOR_RVFI_CH0_WIRES            \
`BICANTOR_RVFI_CH1_WIRES            \
`BICANTOR_CONNECT_WIRES
