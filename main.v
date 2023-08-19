`include "constants.v"
`timescale 1ns / 1ps
`define IN_X 0//for graph creator
`define IN_Y 1
`define READY 2

`define INIT 0// for Dijkstra algorithm
`define LENGTHS_TO_GRAPH 1
`define PARSEY 2
`define SET_CURR 0
`define SET_PATHS 1
`define FIND_PATHS 0
`define FORM_PATHS 1

`define CREATE_GRAPH 0// for algorithm states
`define CREATE_EDGES 1
`define DIJKSTRA 2
`define BTW_CALC 3
`define DELETE_EDGE 4
`define DETECT_COM 5

module main(
//    input[15:0]sw,
//    input clk, enter, ready, rst,
//    output[0:`MAX_NODES*`MAX_NODES-1] graph_fin
    input clk
    );
    
    reg[`NODE_WIDTH:0] number,x,y;
    reg[2:0] state, new_state;
    reg[0:`MAX_NODES*`MAX_NODES-1] graph;
    reg[3:0] alg_state;
    reg graph_ready, dj_ready, edge_cr_ready, btw_ready, deleter_ready, detect_ready;
    reg[1:0]for_a, for_b;
    integer a,b,pnt;
    reg[0:(`NODE_WIDTH*2+5)*`MAX_NODES-1] edges;
    reg[(`NODE_WIDTH+1)*`MAX_NODES-1:0]coms[0:`NODE_WIDTH*`NODE_WIDTH-1];
    
    reg[4:0] paths[0:`MAX_NODES-1][0:`MAX_NODES-1];
    reg[79:0]paths_s[0:`MAX_NODES-1][0:`MAX_NODES-1];
    reg[4:0] lengths[0:`MAX_NODES-1][0:`MAX_NODES-1];
    reg marked[0:`MAX_NODES-1];
    reg[4:0] curr, add_len;
    reg[2:0] state_x, for_x, for_y, for_curr, for_paths, for_t, for_v, for_k, for_j, while_st,for_w;
    reg[1:0] state_y;
    reg[9:0] temp;
    reg state_dj;
    integer i;
    integer k,j,v,t,zz,jz,kz,w;
    reg[4:0] min_length;
    
    integer delim_s,delim_e;
    reg[7:0]curr_edge,curr_edge_inv,max_edge;
    reg[3:0] fst,scd;
    reg[7:0] curr_sample;
    reg[5*`MAX_NODES-1:0]curr_path;
    reg[2:0]for_i;
    reg[4:0]btw, max_btw;
    
    
    assign graph_fin = graph;
    
    initial begin 
        //graph<=graph_in;
        graph=0;
        edges<=0; number<=0; state<=`IN_X; new_state <=0;x<=0;y<=0;alg_state<=5;graph_ready<=0;
        dj_ready<=0;edge_cr_ready<=0;btw_ready<=0;deleter_ready<=0;detect_ready<=0;for_a<=0;for_b<=0;
        temp<=0;for_x<=0;for_y<=0;for_t<=0;for_v<=0;for_curr<=0;for_paths<=0;for_k<=0;for_j<=0;for_w<=0;
        a<=0;b<=0;i<=0;w<=0;t<=0;v<=0;
        max_edge<=0;max_btw<=0;
        
        for(jz=0;jz<`MAX_NODES;jz=jz+1) begin
            for(kz=0;kz<`MAX_NODES;kz=kz+1) lengths [jz][kz]<=0;
        end
        for(jz=0;jz<`MAX_NODES;jz=jz+1) begin
            for(kz=0;kz<`MAX_NODES;kz=kz+1) begin
                for(zz=0;zz<`MAX_NODES*5;zz=zz+(`NODE_WIDTH+1)) paths_s [jz][kz][zz+:(`NODE_WIDTH+1)]<=5'b10000;
            end
        end
        for(jz=0;jz<`MAX_NODES;jz=jz+1) begin
            for(kz=0;kz<`MAX_NODES;kz=kz+1) paths [jz][kz]<=0;
        end
        for(jz=0;jz<`MAX_NODES;jz=jz+1)begin
            for(kz=0;kz<(`NODE_WIDTH+1)*`MAX_NODES;kz=kz+`NODE_WIDTH+1)coms [jz][kz+:(`NODE_WIDTH+1)]<=5'b10000;
        end 
        for(jz=0;jz<`MAX_NODES;jz=jz+1) marked[jz]<=0;
        curr<=0;
        state_x<=0;state_y<=0;state_dj<=0;while_st<=0;pnt<=0;add_len<=0;min_length <= 5'd16;
        curr_edge <=0;curr_path <=0;delim_e<=0;delim_s<=0;curr_edge_inv <=0;
        for_i<=0;for_j<=0;for_k<=0;i<=0;j<=0;k<=0;pnt<=0;while_st<=0;curr_sample<=0;btw<=0;
        
        graph[{4'h1,4'h0}]=1;
        graph[{4'h0,4'h1}]=1;
    
        graph[{4'h2,4'h0}]=1;
        graph[{4'h0,4'h2}]=1;
    
        graph[{4'h1,4'h2}]=1;
        graph[{4'h2,4'h1}]=1;
    
        graph[{4'h2,4'h3}]=1;
        graph[{4'h3,4'h2}]=1;
    
        graph[{4'h3,4'h4}]=1;
        graph[{4'h4,4'h3}]=1;
    
        graph[{4'h4,4'h5}]=1;
        graph[{4'h5,4'h4}]=1;
    
        graph[{4'h3,4'h5}]=1;
        graph[{4'h5,4'h3}]=1;
        
    end
    
//    always@(sw) begin
//        case(sw)
//            16'h1: number<=4'h0;
//            16'h2: number<=4'h1;
//            16'h4: number<=4'h2;
//            16'h8: number<=4'h3;
//            16'h10: number<=4'h4;
//            16'h20: number<=4'h5;
//            16'h40: number<=4'h6;
//            16'h80: number<=4'h7;
//            16'h100: number<=4'h8;
//            16'h200: number<=4'h9;
//            16'h400: number<=4'ha;
//            16'h800: number<=4'hb;
//            16'h1000: number<=4'hc;
//            16'h2000: number<=4'hd;
//            16'h4000: number<=4'he;
//            16'h8000: number<=4'hf;
//        endcase 
//    end
    
    always@(posedge clk)begin
        state <= new_state; 
        
        case(alg_state)
            `CREATE_GRAPH:begin
                if(graph_ready)alg_state=alg_state+1;
            end
            
            `CREATE_EDGES:begin
                case(for_a)
                    0:begin
                        if(a<`MAX_NODES)for_a=1;
                        else for_a=2;
                    end
                    
                    1:begin
                        case(for_b)
                            0:begin
                                if(b<(a+1))for_b=1;
                                else for_b=2;
                             end
                             
                             1:begin
                                if(graph[{a[3:0],b[3:0]}])begin
                                    edges[pnt+:(`NODE_WIDTH*2+5)] = {a[3:0],b[3:0],5'h0};
                                    pnt=pnt+4'd13;
                                end
                                b=b+1;
                                for_b=0;
                             end
                             
                             2:begin
                                for_b=0;
                                for_a=0;
                                a=a+1;
                                b=0;
                             end
                        endcase

                    end
                    
                    2:begin
                        alg_state=alg_state+1;
                        a=0;
                    end
                endcase
            end
            
            `DIJKSTRA:begin
    case(state_dj)
        `FIND_PATHS:begin
        case(for_x)
        0:begin
            if(x<`MAX_NODES) begin
                for_x = 1;
            end
            else for_x = 2;
        end
    
        1:begin
            case(state_x)
            `INIT:begin
                for(i=0;i<`MAX_NODES;i=i+1)begin
                    paths[x][i] <= x;
                end
                lengths[x][x] = 0;
                state_x=state_x+1;
            end
            
            `LENGTHS_TO_GRAPH:begin
                i=0;
                for(i=0;i<`MAX_NODES;i=i+1)begin
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
                        if(y<`MAX_NODES) begin
                            for_y = 1;
                        end
                        else for_y = 2;
                    end
                    
                    1:begin
                        case(state_y)
                            `SET_CURR:begin
                                case(for_curr)
                                    0:begin
                                        if(k<`MAX_NODES) begin
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
                                        if(j<`MAX_NODES) begin
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
                                        else if(lengths[x][j]==`MAX_NODES) 
                                            paths[x][j[3:0]] = j[3:0];
                                        for_paths=0;
                                        j=j+1;
                                    end
                                    
                                    2:begin
                                        for_y=0;
                                        y=y+1;
                                        state_y=0;
                                        min_length = `MAX_NODES;
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
                    if(t<`MAX_NODES)for_t=1;
                    else for_t=2;
                end
                
                1:begin
                    case(for_v)
                        0:begin
                            if(v<`MAX_NODES)for_v=1;
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
                
                2:alg_state=alg_state+1;
            endcase
        end
    endcase
            end
            
            `BTW_CALC:begin
                case(for_w)
            0:begin
                if(w<`MAX_NODES)for_w=1;
                else for_w=2;
            end
            
            1:begin
                case(for_j)
                    0:begin
                        if(j<`MAX_NODES)for_j=1;
                        else for_j=3;
                    end
                    
                    1:begin
                        curr_path = paths_s[w][j];
                        for_j=2;
                        pnt=0;
                        if(w==j)begin
                            for_j=0;
                            j=j+1;
                        end 
                    end
                    
                    2:begin
                        case(while_st)
                            0:begin
                                if(curr_path[(pnt+5)+:5] != 5'b10000)begin
                                    while_st=1;
                                    for_k=0;
                                    k=0;
                                end
                                else while_st=2;
                            end
                            
                            1:begin
                                case(for_k)
                                    0:begin
                                        if(k<(`NODE_WIDTH*2+5)*`MAX_NODES)begin
                                            for_k=1;
                                        end
                                        else for_k=2;
                                    end
                                    
                                    1:begin
                                        delim_s = pnt+5;
                                        curr_sample={curr_path[pnt+:4], curr_path[delim_s+:4]};
                                        delim_e = k+4;
                                        fst = edges[k+:4];
                                        scd = edges[delim_e+:4];
                                        btw=edges[(delim_e+4)+:5];
                                        curr_edge = {fst,scd};
                                        curr_edge_inv = {scd,fst};
                                        
                                        if((curr_edge == curr_sample)||(curr_edge_inv == curr_sample))begin
                                            btw=btw+1;
                                            edges[k+:(`NODE_WIDTH*2+5)]={curr_edge,btw};
                                            pnt=pnt+5;
                                            while_st=0;
                                        end
                                        
                                        else k=k+(`NODE_WIDTH*2+5);
                                    end
                                endcase
                            end
                            
                            2:begin
                                for_j=0;
                                j=j+1;
                                while_st=0;
                            end
                        endcase
                    end
                    
                    3:begin
                        for_j=0;
                        j=0;
                        for_w=0;
                        w=w+1;
                    end
                endcase
            end
            
            2:begin
                for_k=0;
                k=0;
                for_w=3;
            end
            
            3:begin
                case(for_k)
                    0:begin
                        if(k<(`NODE_WIDTH*2+5)*`MAX_NODES)begin
                            for_k=1;
                        end
                        else for_k=2;
                    end
                    
                    1:begin
                        delim_e=k+`NODE_WIDTH*2;
                        edges[delim_e+:5] = edges[delim_e+:5]>>1;
                        k=k+(`NODE_WIDTH*2+5);
                        for_k=0;
                    end
                    
                    2:begin
                        alg_state=alg_state+1;
                        for_k=0;
                        k=0;
                    end
                endcase
            end
        endcase
            end
            
            `DELETE_EDGE:begin
                case(for_k)
                    0:begin
                        if(k<(`NODE_WIDTH*2+5)*`MAX_NODES)begin
                            for_k=1;
                        end
                        else for_k=2;
                    end
                    
                    1:begin
                        delim_e=k+`NODE_WIDTH*2;
                        btw=edges[delim_e+:5];
                        if(btw>max_btw)begin
                            max_btw=btw;
                            max_edge=edges[k+:`NODE_WIDTH*2];
                        end
                        k=k+(`NODE_WIDTH*2+5);
                        for_k=0;
                    end
                    
                    2:begin
                        for_k=3;
                        k=0;
                    end
                    
                    3:begin
                        fst=max_edge[3:0];
                        scd=max_edge[7:4];
                        for_k=4;
                    end
                    
                    4:begin
                        if(k<(`NODE_WIDTH*2+5)*`MAX_NODES)begin
                            for_k=5;
                        end
                        else for_k=6;
                    end
                    
                    5:begin
                        if(edges[k+:(`NODE_WIDTH*2)]==max_edge) 
                            edges[k+:(`NODE_WIDTH*2+5)]=13'd0;
                        
                        for_k=4;
                        k=k+(`NODE_WIDTH*2+5);
                    end
                    
                    6:begin
                        graph[{fst,scd}]=0;
                        graph[{scd,fst}]=0;
                        alg_state=alg_state+1;
                        for_i=0;i=0;j=0;k=0;pnt=0;
                        for_j=0;
                        for_k=0;
                    end
                endcase
            end
            
            `DETECT_COM:begin
                case(for_i)
                    0:begin
                        if(i<`MAX_NODES) for_i=1;
                        else for_i=2;
                    end
                    
                    1:begin
                        case(for_j)
                            0:begin
                                if(j<=pnt) for_j=1;
                                else for_j=2;
                            end
                            
                            1:begin
                                case(for_k)
                                    0:begin
                                        if(coms[j][k+:`NODE_WIDTH+1]!=5'b10000) for_k=1;
                                        else begin
                                            for_j=2;
                                            for_k=0;
                                            k=0;
                                        end
                                    end
                                    
                                    1:begin
                                        y=coms[j][k+:`NODE_WIDTH+1];
                                        if(graph[{i[3:0],y[3:0]}])begin
                                            coms[j]=(coms[j] << 5) + i[4:0];
                                            i=i+1;
                                            for_i=0;
                                            for_k=0;
                                            k=0;
                                            for_j=0;
                                            j=0;
                                        end
                                        else begin
                                            k=k+`NODE_WIDTH+1;
                                            for_k=0;
                                        end
                                    end
                                   
                                endcase
                            end
                            
                            2:begin
                                coms[pnt]=(coms[pnt]<<5) + i[4:0];
                                for_i=0;
                                for_j=0;
                                j=0;
                                i=i+1;
                                for_i=0;
                                pnt=pnt+1;
                            end
                        endcase
                    end
                    
                    2:begin
                        alg_state=alg_state+1;
                    end
                endcase
            end
        endcase
    end
    
    always@(posedge enter or posedge ready or posedge rst)begin
        if(rst)state <= `IN_X;
        else begin
            case(state)
                `IN_X:begin
                    if(ready)begin
                        new_state = `READY;
                        graph_ready=1;
                    end 
                    else if(enter) new_state = `IN_Y;
                end
                `IN_Y: if(enter) new_state = `IN_X;
            endcase
        end
        
    end
    
    always@(posedge enter or posedge rst)begin
        if(rst)begin 
            x<=0;
            y<=0;
            graph<=0;
        end
        else begin
            case(state)
                `IN_X: if(enter) x<=number;
                  
                `IN_Y: if(enter) begin
                    y=number;
                    graph[{x,y}]=1;
                    graph[{y,x}]=1;
                  end
            endcase
        end
    end
    
endmodule
