// ----------------------------------------------------------------------------
// FILE:          pll_ps_av.vhd
// DESCRIPTION:   Phase shift module with avalon MM interface based on 
//                Altera pll_reconfig_dps example
// DATE:          11:21 AM Friday, January 19, 2018
// AUTHOR(s):     Lime Microsystems
// REVISIONS:
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// NOTES: Works in Polling Mode
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Module declaration
// ----------------------------------------------------------------------------
module pll_ps_av (
    clk,
    reset_n,
    busy,       // 1 - busy, 0 - not busy
    en,         // rising edge triggers dynamic phase shift
    phase,      // phase value in steps
    cnt,        // 00000 -  C0, 00001 -  C1, 00010 - C2,
                // 00011 -  C3, 00100 -  C4, 00101 - C5,
                // .....
                // 10010 -   M, 11111 - All,
                
    updown,     // 1- UP, 0 - DOWN 
    
    // AVMM bus 
    mgmt_readdata,
    mgmt_waitrequest,
    mgmt_read,
    mgmt_write,
    mgmt_address,
    mgmt_writedata
    );
    
input clk, reset_n, en;
input[15:0] phase;
input[4:0] cnt;
input updown;
input[31:0] mgmt_readdata;
input mgmt_waitrequest;
output mgmt_read,mgmt_write, busy;
output[5:0] mgmt_address;
output[31:0] mgmt_writedata;


reg [3:0] state;
reg [3:0] write_count;
reg mgmt_read;
reg mgmt_write;
reg [5:0] mgmt_address;
reg [31:0] mgmt_writedata;
reg busy;
reg en_reg;

// ----------------------------------------------------------------------------
// Input registers
// ----------------------------------------------------------------------------
always @ (posedge clk or negedge reset_n)
begin 
    if (reset_n == 1'b0)
        en_reg <= 1'b0;   
    else 
        en_reg <= en;
end
    
// ----------------------------------------------------------------------------
// FSM
// ----------------------------------------------------------------------------
always @ (posedge clk or negedge reset_n)
begin
    if (reset_n == 1'b0)
    begin
        state <= 4'b0000;
        mgmt_read<=1'b0;
        mgmt_write<=1'b0;
        mgmt_address<=5'b00000;
        mgmt_writedata<=32'h00000000;	
        write_count<=4'b0000;
    end

    else 
    begin

        case (state)
            4'b0000: 
                begin
                    if (en == 1'b1 & en_reg == 1'b0) 
                    begin 
                        state <= 4'b0001;
                    end
                    else 
                    begin
                        state <= 4'b0000;
                    end 
                    
                    mgmt_read<=1'b0;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000000;
                    mgmt_writedata<=32'h00000001;	
                    //Setting up data : Mode Register(Add=0), Data=1 , Mode=Polling Mode

                end
                
            4'b0001: 
                begin
                    // 
                    if (mgmt_waitrequest == 1'b1)
                        begin 
                            write_count <= 4'b0000;
                        end
                    else
                        begin
                            write_count<=write_count+1'b1;
                        end
                    
                    mgmt_read<=1'b0;
                    mgmt_address<=6'b000000;
                    mgmt_writedata<=32'h00000001;	
                    
                    if(write_count==4'b0000 & mgmt_waitrequest == 1'b1)
                    begin
                        mgmt_write<=1'b1;
                    end
                    
                else mgmt_write<=1'b0;	
                    
                    if(write_count==4'b0001)
                    begin 
                        state <= 4'b0010;
                        write_count<=4'b0000;
                    end
                    
                else state<=4'b0001;
                    
                    
                    //Writing to Mode Register
                    
                end
                
            4'b0010: 
                begin
                    state <= 4'b0011;
                    mgmt_read<=1'b0;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000110;
                    mgmt_writedata[31:22] <= 10'b0000000000; // Unused
                    mgmt_writedata[21]    <= updown; // The direction of the shift
                    mgmt_writedata[20:16] <= cnt;    // Which counter output is shifted
                    mgmt_writedata[15:0]  <= phase;  // Number of shifts               
                end
                
                
            4'b0011: 
                begin
                    if (mgmt_waitrequest == 1'b1)
                        begin 
                            write_count <= 4'b0000;
                        end
                    else
                        begin
                            write_count<=write_count+1'b1;
                        end
                    mgmt_read<=1'b0;
                    mgmt_address<=6'b000110;
                    mgmt_writedata[31:22] <= 10'b0000000000;
                    mgmt_writedata[21]    <= updown;
                    mgmt_writedata[20:16] <= cnt;
                    mgmt_writedata[15:0]  <= phase; 
                    //Writing to DPS register
                    
                    if(write_count==4'b0000 & mgmt_waitrequest == 1'b1)
                    begin
                        mgmt_write<=1'b1;
                    end
    
                    else mgmt_write<=1'b0;
                        
                    if(write_count==4'b0001)
                    begin 
                        state <= 4'b0100;
                        write_count<=4'b0000;
                    end
                    
                else state<=4'b0011;
                end
                 
            4'b0100: 
                begin
                    state <= 4'b0101;
                    mgmt_read<=1'b0;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000010;
                    mgmt_writedata<=32'b00000000000000000000000000000001;	
                    //Setting up data 
                end
                
            4'b0101: 
                begin
                    if (mgmt_waitrequest == 1'b1)
                        begin 
                            write_count <= 4'b0000;
                        end
                    else
                        begin
                            write_count<=write_count+1'b1;
                        end
                    mgmt_read<=1'b0;
                    mgmt_address<=6'b000010;
                    mgmt_writedata<=32'b00000000000000000000000000000001;	
                    //Writing to Start Register
                    
                    if(write_count==4'b0000 & mgmt_waitrequest == 1'b1)
                    begin
                        mgmt_write<=1'b1;
                    end
                    
                else mgmt_write<=1'b0;
                    
                                        
                    if(write_count==4'b001)
                    begin 
                        state <= 4'b0110;
                        write_count<=4'b0000;
                    end
                    
                else state<=4'b0101;
                end			
                
            4'b0110: 
                begin
                    state <= 4'b0111;
                    mgmt_read<=1'b0;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000001;
                    mgmt_writedata<=32'b00000000000000000000000000000001;	
                    //Setting to read from status Register
                end	
                
            4'b0111: 
                begin
                    mgmt_read<=1'b1;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000001;
                    
                    if (mgmt_readdata[0]==1'b1 & mgmt_waitrequest == 1'b0) 
                    begin 
                        state <= 4'b1000;
                    end
                    
                    else state<=4'b0111;
                    //only proceed to next operation if status register =1                   
                end	
                
            4'b1000: 
                begin
                    mgmt_read<=1'b0;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000000;
                    mgmt_writedata<=32'h00000000;
                    state <= 4'b0000;
                    //GO TO 0000 state
                end
            
            default:
                begin
                    mgmt_read<=1'b0;
                    mgmt_write<=1'b0;
                    mgmt_address<=6'b000000;
                    mgmt_writedata<=32'h00000000;	
                end		
                    
    endcase
    
    end
end

// ----------------------------------------------------------------------------
// Output registers
// ----------------------------------------------------------------------------

always @ (posedge clk or negedge reset_n)
begin 
    if (reset_n == 1'b0)
        busy <= 1'b1; 
    else 
        begin
            if (state == 4'b0000)
                busy <= 1'b0;
            else
                busy <= 1'b1;
        end
end

endmodule
