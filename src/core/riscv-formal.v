`define NRET 2
`define CORE_RVFI_IO                                \
,output wire [`NRET      - 1:0]  rvfi_valid         \
,output wire [`NRET * 64 - 1:0]  rvfi_order         \
,output wire [`NRET * 32 - 1:0]  rvfi_insn          \
,output reg  [`NRET      - 1:0]  rvfi_trap      = 0 \
,output reg  [`NRET      - 1:0]  rvfi_halt      = 0 \
,output reg  [`NRET      - 1:0]  rvfi_intr      = 0 \
,output reg  [`NRET *  2 - 1:0]  rvfi_mode      = 0 \
,output reg  [`NRET *  2 - 1:0]  rvfi_ixl       = 0 \
,output wire [`NRET *  5 - 1:0]  rvfi_rs1_addr      \
,output wire [`NRET *  5 - 1:0]  rvfi_rs2_addr      \
,output wire [`NRET * 32 - 1:0]  rvfi_rs1_rdata     \
,output wire [`NRET * 32 - 1:0]  rvfi_rs2_rdata     \
,output wire [`NRET *  5 - 1:0]  rvfi_rd_addr       \
,output wire [`NRET * 32 - 1:0]  rvfi_rd_wdata      \
,output wire [`NRET * 32 - 1:0]  rvfi_pc_rdata      \
,output wire [`NRET * 32 - 1:0]  rvfi_pc_wdata      \
,output reg  [`NRET * 32 - 1:0]  rvfi_mem_addr  = 0 \
,output reg  [`NRET *  4 - 1:0]  rvfi_mem_rmask = 0 \
,output reg  [`NRET *  4 - 1:0]  rvfi_mem_wmask = 0 \
,output reg  [`NRET * 32 - 1:0]  rvfi_mem_rdata = 0 \
,output reg  [`NRET * 32 - 1:0]  rvfi_mem_wdata = 0
