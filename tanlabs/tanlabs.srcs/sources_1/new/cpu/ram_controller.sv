`default_nettype none
module ram_controller(input wire clk,
                      input wire rst,
                      input wire if_ram_req,
                      input wire mem_ram_req,
                      input wire [31:0] pc_ram_addr_o,
                      input wire[31:0] mem_ram_addr_o,
                      input wire [31:0] mem_ram_data_o,
                      input wire [3:0] mem_ram_be_o,
                      input wire mem_ram_we_o,
                      input wire mem_ram_oe_o,
                      output reg if_ram_ready,
                      output reg mem_ram_ready,
                      output reg[31:0] ram_data_o,
                      output reg[31:0] ram_addr_o,
                      output reg[3:0] ram_be_o,
                      output reg ram_we_o,
                      output reg ram_oe_o,
                      output reg if_stall,
                      output reg mem_stall,
                      output reg ram_req,
                      input wire ram_ready
                      );
    typedef enum logic[1:0] { IDLE, IF, MEM } state_t;
    state_t state, next_state;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state     <= IDLE;
        end
        else begin
            state     <= next_state;
        end
    end

    always_comb begin
        case (next_state)
        MEM: begin
            ram_data_o                       = mem_ram_data_o;
            ram_addr_o                       = mem_ram_addr_o;
            ram_be_o                         = mem_ram_be_o;
            ram_we_o                         = mem_ram_we_o;
            ram_oe_o                         = mem_ram_oe_o;
        end
        IF: begin
            ram_data_o                       = 0;
            ram_addr_o                       = pc_ram_addr_o;
            ram_be_o                         = 4'b1111;
            ram_we_o                         = 0;
            ram_oe_o                         = 1;
        end
        default: begin
            case (state)
                MEM: begin
                    ram_data_o                       = mem_ram_data_o;
                    ram_addr_o                       = mem_ram_addr_o;
                    ram_be_o                         = mem_ram_be_o;
                    ram_we_o                         = mem_ram_we_o;
                    ram_oe_o                         = mem_ram_oe_o;
                end
                IF: begin
                    ram_data_o                       = 0;
                    ram_addr_o                       = pc_ram_addr_o;
                    ram_be_o                         = 4'b1111;
                    ram_we_o                         = 0;
                    ram_oe_o                         = 1;
                end
                default: begin
                    ram_data_o = 0;
                    ram_addr_o = 0;
                    ram_be_o   = 0;
                    ram_we_o   = 0;
                    ram_oe_o   = 1;
                end       
            endcase
        end       
        endcase
    end

    always_comb begin
        case(state)
            MEM: begin
                if (ram_ready) next_state  = IDLE;
                else next_state = MEM;
            end
            IF: begin
                if (ram_ready) next_state  = IDLE;
                else next_state = IF;
            end
            default:begin
                if (mem_ram_req) begin
                    next_state = MEM;
                end
                else if (if_ram_req) begin
                    next_state = IF;
                end
                else begin
                    next_state = IDLE;
                end
            end
        endcase
        mem_ram_ready = state == MEM && ram_ready;
        if_ram_ready  = state == IF && ram_ready;
        if_stall      = !if_ram_ready && if_ram_req;
        mem_stall     = !mem_ram_ready && mem_ram_req;
        ram_req       = if_ram_req || mem_ram_req;
    end
endmodule
