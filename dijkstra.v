`timescale 1ns / 1ps
`define INIT 0
`define LENGTHS_TO_GRAPH 1
`define PARSEY 2
`define SET_CURR 0
`define SET_PATHS 1
`define FIND_PATHS 0
`define FORM_PATHS 1


module dijkstra(
    input [0:255] graph_in,
    input clk, ce,
    output reg [0:255] paths1
    );
    
parameter max = 5'h10;
reg[0:255] graph;
reg[4:0] paths[0:max-1][0:max-1];
reg[79:0]paths_s[0:max-1][0:max-1];
reg[4:0] lengths[0:max-1][0:max-1];
reg marked[0:max-1];
reg[4:0] curr, add_len;
reg[2:0] state_x, for_x, for_y, for_curr, for_paths, for_t, for_v, while_st;
reg[1:0] state_y;
reg[3:0] pnt;
reg[9:0] temp;
reg state_dj;
integer i, y,x;
integer k,j,v,t;
reg[4:0] min_length;


initial begin
    temp<=0;
    for_x<=0;
    for_y<=0;
    for_t<=0;
    for_v<=0;
    for_curr<=0;
    for_paths<=0;
    for(j=0;j<max;j=j+1) begin
        for(k=0;k<max;k=k+1) lengths [j][k]<=0;
    end
    for(j=0;j<max;j=j+1) begin
        for(k=0;k<max;k=k+1) begin
            for(t=0;t<max*5;t=t+5) paths_s [j][k][t+:5]<=5'b10000;
        end
    end
    for(j=0;j<max;j=j+1) begin
        for(k=0;k<max;k=k+1) paths [j][k]<=0;
    end
    for(j=0;j<max;j=j+1) marked[j]<=0;
    curr<=0;
    state_x<=0;
    state_y<=0;
    state_dj<=0;
    while_st<=0;
    pnt<=0;
    add_len<=0;
    min_length <= 5'd16;
end

always@(posedge ce) graph <= graph_in;

always@(posedge clk)begin

    case(state_dj)
        `FIND_PATHS:begin
        case(for_x)
        0:begin
            if(x<max) begin
                for_x = 1;
            end
            else for_x = 2;
        end
    
        1:begin
            case(state_x)
            `INIT:begin
                for(i=0;i<max;i=i+1)begin
                    paths[x][i] <= x;
                end
                lengths[x][x] = 0;
                state_x=state_x+1;
            end
            
            `LENGTHS_TO_GRAPH:begin
                i=0;
                for(i=0;i<max;i=i+1)begin
                    if(i!=x)begin
                        if(graph[{x,i[3:0]}]==0) lengths[x][i] <= 5'h10;
                        else lengths[x][i] <= graph[{x,i[3:0]}];
                    end 
                    marked[i] = 0;
                end
                marked[x] = 1;
                state_x=state_x+1;
            end
            
            `PARSEY:begin
                case(for_y)
                    0:begin
                        if(y<max) begin
                            for_y = 1;
                        end
                        else for_y = 2;
                    end
                    
                    1:begin
                        case(state_y)
                            `SET_CURR:begin
                                case(for_curr)
                                    0:begin
                                        if(k<max) begin
                                            for_curr = 1;
                                        end
                                        else for_curr = 2;
                                    end
                            
                                    1:begin
                                        
                                        if((lengths[x][k] < min_length) && ~marked[k] && (k!=x))begin
                                            curr = k;
                                            min_length = lengths[x][k];
                                        end
                                        
                                        for_curr=0;
                                        k=k+1;
                                    end
                            
                                    2: begin
                                        marked[curr] = 1;
                                        state_y=state_y+1;
                                        k=0;
                                        for_curr=0;
                                    end 
                                endcase
                            end
                            
                            `SET_PATHS:begin
                                case(for_paths)
                                    0:begin
                                        if(j<max) begin
                                            for_paths = 1;
                                        end
                                        else for_paths = 2;
                                    end
                                    
                                    1:begin
                                        if(graph[{curr,j[3:0]}]==0)
                                            add_len = 5'h10;
                                        else add_len = 5'h1;
                                        
                                        temp = lengths[x][curr] + add_len;
                                        
                                        if(j[3:0]!=x && !marked[j[3:0]] && (lengths[x][j[3:0]] > temp))begin
                                            lengths[x][j[3:0]] = temp;
                                            paths[x][j[3:0]] = curr;
                                        end
                                        else if(lengths[x][j]==max) 
                                            paths[x][j[3:0]] = j[3:0];
                                        for_paths=0;
                                        j=j+1;
                                    end
                                    
                                    2:begin
                                        for_y=0;
                                        y=y+1;
                                        state_y=0;
                                        min_length = max;
                                        j=0;
                                        for_paths=0;
                                    end
                                endcase
                            end
                        endcase
                        
                        
                    end
                        
                    2:begin
                        state_x=0;
                        x=x+1;
                        for_x=0;
                        y=0;
                        for_y=0;
                        
                    end
                endcase
            end
            endcase
       end
       
        2:state_dj=state_dj+1;
    endcase
        
        
        end
        
        `FORM_PATHS:begin
            case(for_t)
                0:begin
                    if(t<max)for_t=1;
                    else for_t=2;
                end
                
                1:begin
                    case(for_v)
                        0:begin
                            if(v<max)for_v=1;
                            else for_v=3;
                        end
                        
                        1:begin
                            pnt=v;
                            if(!(pnt==t[3:0]||paths[t[3:0]][v[3:0]]==v[3:0])) for_v=2;
                            else begin
                                v=v+1;
                                for_v=0;
                            end 
                        end
                        
                        2:begin
                            if(pnt==t)begin
                                paths_s[t[3:0]][v[3:0]] = (paths_s[t[3:0]][v[3:0]] << 5) + t[3:0];
                                for_v=1;
                                v=v+1;
                            end
                            else begin
                                paths_s[t[3:0]][v[3:0]] = (paths_s[t[3:0]][v[3:0]] << 5) + pnt[3:0];
                                pnt = paths[t[3:0]][pnt];
                            end
                            
                            
                        end
                        
                        3:begin
                            v=0;
                            t=t+1;
                            for_t=0;
                            for_v=0;
                        end
                    endcase
                end
            endcase
        end
    endcase
    end
 endmodule
