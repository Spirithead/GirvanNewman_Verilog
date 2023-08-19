`include "constants.v"
`timescale 1ns / 1ps

module edge_creator(
    input[0:`MAX_NODES*`MAX_NODES-1] graph_in,
    input ce,
    output reg[0:`NODE_WIDTH*3*`MAX_NODES-1] edges
    );
    
    integer i,j,pnt;
    reg[0:`MAX_NODES*`MAX_NODES-1] graph;
    
    initial begin
        pnt=0;
        edges=0;
        //graph <= graph_in;
        
    end
    
    always@(posedge ce)begin
        for(i=0;i<`Q-1;i=i+1)begin
            for(j=0;j<(i+1);j=j+1)begin
                if(graph_in[{i[3:0],j[3:0]}])begin
                    edges[pnt+:(`NODE_WIDTH*3)] = {i[3:0],j[3:0],4'h0};
                    pnt=pnt+4'd12;
                end
            end
        end
    end
endmodule
