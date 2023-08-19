`include "constants.v"
`timescale 1ns / 1ps

module edge_btw_calc(
    input [79:0]paths_s[0:`MAX_NODES-1][0:`MAX_NODES-1],
    input [0:`NODE_WIDTH*3*`MAX_NODES-1] edges_in,
    input clk,
    output reg [0:(`NODE_WIDTH*2+4)*`MAX_NODES-1] edges_out
    );
    
    integer i,j,k,pnt,delim_s,delim_e;
    reg[7:0]curr_edge,curr_edge_inv;
    reg[4:0] fst,scd;
    reg[7:0] curr_sample;
    reg[5*`MAX_NODES-1:0]curr_path;
    reg[2:0]for_i,for_j,for_k, while_st;
    reg[0:`NODE_WIDTH*3*`MAX_NODES-1] edges;
    reg[3:0]btw;
    
    initial begin
        edges<=edges_in;
        curr_edge <=0;
        curr_edge_inv <=0;
        delim_s<=0;
        delim_e<=0;
        curr_path <=0;
        for_i<=0;for_j<=0;for_k<=0;i<=0;j<=0;k<=0;pnt<=0;while_st<=0;curr_sample<=0;btw<=0;
    end
    
    always@(posedge clk) begin
        case(for_i)
            0:begin
                if(i<`MAX_NODES)for_i=1;
                else for_i=2;
            end
            
            1:begin
                case(for_j)
                    0:begin
                        if(j<`MAX_NODES)for_j=1;
                        else for_j=3;
                    end
                    
                    1:begin
                        curr_path = paths_s[i][j];
                        for_j=2;
                        pnt=0;
                        if(i==j)begin
                            for_j=0;
                            j=j+1;
                        end 
                    end
                    
                    2:begin
                        case(while_st)
                            0:begin
                                if(curr_path[(pnt+1)+:5] == 5'b10000)while_st=1;
                                else while_st=2;
                            end
                            
                            1:begin
                                case(for_k)
                                    0:begin
                                        if(k<`NODE_WIDTH*3*`MAX_NODES)for_k=1;
                                        else for_k=2;
                                    end
                                    
                                    1:begin
                                        delim_s = k+5;
                                        delim_e = k+4;
                                        curr_sample={curr_path[pnt+:4], curr_path[delim_s+:4]};
                                        fst = edges[k+:4];
                                        scd = edges[delim_e+:4];
                                        btw=edges[delim_e*2+:4];
                                        curr_edge = {fst,scd};
                                        curr_edge_inv = {scd,fst};
                                        
                                        if((curr_edge == curr_path)||(curr_edge_inv == curr_path))begin
                                            btw=btw+1;
                                            edges[k+:12]={curr_edge,btw};
                                            pnt=pnt+1;
                                            while_st=0;
                                        end
                                    end
                                endcase
                            end
                            
                            2:begin
                                for_j=0;
                                j=j+1;
                            end
                        endcase
                    end
                    
                    3:begin
                        for_j=0;
                        j=0;
                        for_i=0;
                        i=i+1;
                    end
                endcase
            end
            
            2:begin
                
            end
        endcase
    end
   
endmodule
