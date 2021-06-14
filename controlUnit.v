module controlUnit (
    input clk,rst,start,Zout,
    input [7:0]ins,
    output reg [2:0]aluOp,
    output reg [3:0]incReg,    // {PC, RC, RP, RQ}
    output reg [9:0]wrEnReg,   // {AR, R, PC, IR, RL, RC, RP, RQ, R1, AC}
    output reg [3:0]busSel,
    output reg dMemWrEn,ZWrEn,
    output done,ready
);

// all the states (47) for the instructions are as follows

localparam  IDLE = 6'd0,  //states

            NOP1 = 6'd1,

            ENDOP1 = 6'd2,

            CLAC1 = 6'd3,

            FETCH_DELAY1 = 6'd37,     /////(extra_delay for memory ip core)
            FETCH1 = 6'd4,
            FETCH2 = 6'd5,

            LDIAC_DELAY1 =  6'd38,     ///// (extra_delay for memory ip core)
            LDIAC1 = 6'd6,
            LDIAC2 = 6'd7,
            LDIAC_DELAY2 = 6'd39,       //// (extra_delay for memory ip core)
            LDIAC3 = 6'd8,

            LDAC1 = 6'd9,
            LDAC_DELAY1 = 6'd40,       ///// (extra_delay for memory ip core)
            LDAC2 = 6'd10,

            STIR_DELAY1 = 6'd41,       ///// (extra_delay for memory ip core)
            STIR1 = 6'd11,
            STIR2 = 6'd12,
            STIR_DELAY2 = 6'd42,       ///// (extra_delay for memory ip core)
            STIR3 = 6'd13,

            STR1 = 6'd14,
            STR_DELAY1 = 6'd43,         ///// (extra_delay for memory ip core)
            STR2 = 6'd15,

            JUMP_DELAY1 = 6'd44,        ///// (extra_delay for memory ip core)
            JUMP1 = 6'd16,
            JUMP2 = 6'd17,
            
            JMPNZY_DILAY1 = 6'd45,      ///// (extra_delay for memory ip core)
            JMPNZY1 = 6'd18,
            JMPNZY2 = 6'd19,
            JMPNZN1 = 6'd20,

            JMPZY_DELAY1 = 6'd46,       ///// (extra_delay for memory ip core)
            JMPZY1 = 6'd21,
            JMPZY2 = 6'd22,
            JMPZN1 = 6'd23,

            MUL1 = 6'd24,

            ADD1 = 6'd25,

            SUB1 = 6'd26,

            INCAC1 = 6'd27,

            MV_RL_AC1 = 6'd28,

            MV_RP_AC1 = 6'd29,

            MV_RQ_AC1 = 6'd30,

            MV_RC_AC1 = 6'd31,

            MV_R_AC1 = 6'd32,

            MV_R1_AC1 = 6'd33,

            MV_AC_RP1 = 6'd34,

            MV_AC_RQ1 = 6'd35,

            MV_AC_RL1 = 6'd36;

localparam  clr_alu = 3'd0,   //alu operations
            pass_alu = 3'd1,
            add_alu =  3'd2,
            sub_alu =  3'd3,
            mul_alu =  3'd4,
            inc_alu =  3'd5,
            idle_alu = 3'dx;

localparam  DMem_bus = 4'b0,   //multiplexer
            R_bus = 4'd1,
            IR_bus = 4'd2,
            RL_bus = 4'd3,
            RC_bus = 4'd4,
            RP_bus = 4'd5,
            RQ_bus = 4'd6,
            R1_bus = 4'd7,
            AC_bus = 4'd8,
            idle_bus = 4'd9;

localparam   //instruction set (assemly instructions and their machine codes)
            NOP	=8'd0,
            ENDOP=	8'd1,
            CLAC=	8'd2,
            LDIAC=	8'd3,
            LDAC=	8'd4,
            STR=	8'd5,
            STIR=	8'd6,
            JUMP=	8'd7,
            JMPNZ=	8'd8,
            JMPZ=	8'd9,
            MUL	=8'd10,
            ADD	=8'd11,
            SUB	=8'd12,
            INCAC	=8'd13,
            MV_RL_AC=	{4'd1,4'd15},
            MV_RP_AC=	{4'd2,4'd15},
            MV_RQ_AC=	{4'd3,4'd15},
            MV_RC_AC=	{4'd4,4'd15},
            MV_R_AC =	{4'd5,4'd15},
            MV_R1_AC=	{4'd6,4'd15},
            MV_AC_RP=	{4'd7,4'd15},
            MV_AC_RQ=	{4'd8,4'd15},
            MV_AC_RL=	{4'd9,4'd15};


reg [5:0]currentState, nextState;

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        currentState <= IDLE;
    end
    else begin
        currentState <= nextState;
    end
end

//all the control signals for each state are set as below
always @(start, Zout, ins, currentState) begin
    case (currentState)    
        IDLE: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'd0;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;

            if (~start)
                nextState <= FETCH1;
            else
                nextState <= IDLE;
        end

        NOP1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'd0;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH1;
        end

        ENDOP1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'd0;
            busSel <= DMem_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= ENDOP1;
        end

        CLAC1: begin
            aluOp <= clr_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'd1;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH1;
        end

        FETCH_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH1;
        end

        FETCH1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH2;
        end

        FETCH2: begin
            aluOp <= idle_alu;
            incReg <= 4'b1000;
            wrEnReg <= 10'd0;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            case (ins)   //has to deside what is the next state 

                NOP: nextState <= NOP1;
                ENDOP: nextState <= ENDOP1;
                CLAC: nextState <= CLAC1;
                LDIAC: nextState <= LDIAC_DELAY1; 
                LDAC: nextState <= LDAC1;
                STR: nextState <= STR1;
                STIR: nextState <= STIR_DELAY1;   
                JUMP: nextState <= JUMP_DELAY1;  
                JMPNZ: nextState <= (Zout == 0)? JMPNZY_DILAY1 : JMPNZN1; 
                JMPZ: nextState <= (Zout == 1)? JMPZY_DELAY1 : JMPZN1;  
                MUL: nextState <= MUL1;
                ADD: nextState <= ADD1;
                SUB: nextState <= SUB1;
                INCAC: nextState <= INCAC1;
                MV_RL_AC: nextState <= MV_RL_AC1;
                MV_RP_AC: nextState <= MV_RP_AC1;
                MV_RQ_AC: nextState <= MV_RQ_AC1;
                MV_RC_AC: nextState <= MV_RC_AC1;
                MV_R_AC: nextState <= MV_R_AC1;
                MV_R1_AC: nextState <= MV_R1_AC1;
                MV_AC_RP: nextState <= MV_AC_RP1;
                MV_AC_RQ: nextState <= MV_AC_RQ1;
                MV_AC_RL: nextState <= MV_AC_RL1;
                default : nextState <= IDLE;                    
                
            endcase
        end

        LDIAC_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= LDIAC1;
        end

        LDIAC1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= LDIAC2;
        end

        LDIAC2: begin
            aluOp <= idle_alu;
            incReg <= 4'b1000;
            wrEnReg <= 10'b1000000000;
            busSel <= IR_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= LDIAC_DELAY2;
        end

        LDIAC_DELAY2: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= DMem_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= LDIAC3;
        end

        LDIAC3: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= DMem_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        LDAC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b1000000000;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= LDAC_DELAY1;
        end

        LDAC_DELAY1: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= DMem_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= LDAC2;
        end

        LDAC2: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= DMem_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        STR1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b1000000000;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= STR_DELAY1;
        end

        STR_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
            nextState <= STR2;
        end

        STR2: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
            nextState <= FETCH1;
        end

        STIR_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0001000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= STIR1;
        end

        STIR1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0001000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= STIR2;
        end

        STIR2: begin
            aluOp <= idle_alu;
            incReg <= 4'b1000;
            wrEnReg <= 10'b1000000000;
            busSel <= IR_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= STIR_DELAY2;
        end

        STIR_DELAY2: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
            nextState <= STIR3;
        end

        STIR3: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b1;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        JUMP_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= JUMP1;
        end

        JUMP1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= JUMP2;
        end

        JUMP2: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0010000000;
            busSel <= IR_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        JMPNZY_DILAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= JMPNZY1;
        end

        JMPNZY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= JMPNZY2;
        end

        JMPNZY2: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0010000000;
            busSel <= IR_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        JMPNZN1: begin
            aluOp <= idle_alu;
            incReg <= 4'b1000;
            wrEnReg <= 10'b0000000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        JMPZY_DELAY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= JMPZY1;
        end

        JMPZY1: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0001000000;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= JMPZY2;
        end

        JMPZY2: begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'b0010000000;
            busSel <= IR_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        JMPZN1: begin
            aluOp <= idle_alu;
            incReg <= 4'b1000;
            wrEnReg <= 10'b0000000000;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MUL1: begin
            aluOp <= mul_alu;
            incReg <= 4'b0111;
            wrEnReg <= 10'b0000000001;
            busSel <= R1_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        ADD1: begin
            aluOp <= add_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= R_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        SUB1: begin
            aluOp <= sub_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= RC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        INCAC1: begin
            aluOp <= inc_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= idle_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        MV_RL_AC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000100000;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MV_RP_AC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000001000;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MV_RQ_AC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000100;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MV_RC_AC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000010000;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MV_R_AC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0100000000;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MV_R1_AC1: begin
            aluOp <= idle_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000010;
            busSel <= AC_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= FETCH_DELAY1;
        end

        MV_AC_RP1: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= RP_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        MV_AC_RQ1: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= RQ_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        MV_AC_RL1: begin
            aluOp <= pass_alu;
            incReg <= 4'b0000;
            wrEnReg <= 10'b0000000001;
            busSel <= RL_bus;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b1;
            nextState <= FETCH_DELAY1;
        end

        default : begin
            aluOp <= idle_alu;
            incReg <= 4'd0;
            wrEnReg <= 10'd0;
            busSel <= 4'd0;
            dMemWrEn <= 1'b0;
            ZWrEn <= 1'b0;
            nextState <= IDLE;
        end            

    endcase
    
end

// signals to the user whether processor is ready or the process is over
assign done = (currentState == ENDOP1)?1'b1:1'b0;
assign ready = (currentState == IDLE)? 1'b1:1'b0;

endmodule //controlUnit