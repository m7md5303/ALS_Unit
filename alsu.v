module ALSU (clk,rst,A,B,cin,serial_in,red_op_A,red_op_B,opcode,bypass_A,bypass_B,direction,leds);
parameter INPUT_PRIORITY="A";
parameter FULL_ADDER="ON";
//a new parameter to be displayed at the two most significant seven segement leds
parameter DASH=11;
//a new parameter for the letter E
parameter E=12;
input clk,rst,cin,serial_in,red_op_A,red_op_B,bypass_A,bypass_B,direction;
input [2:0] A,B,opcode;
output [15:0] leds;
reg cin_ff,serial_in_ff,red_op_A_ff,red_op_B_ff,bypass_A_ff,bypass_B_ff,direction_ff;
reg [2:0] A_ff,B_ff,opcode_ff;
reg [15:0] leds_tmp;
reg [5:0] out;
wire invalid_case;
assign invalid_case=(((red_op_A_ff)&&(red_op_B_ff)&&(!{opcode_ff[2],opcode_ff[1]}))||(opcode_ff==3'b110)||(opcode_ff==3'b111))?1'b1:0;
wire [5:0] mult_out;
wire [3:0] add_out;
mult_alsu m_inst (
  .A(A_ff),  // input wire [2 : 0] A
  .B(B_ff),  // input wire [2 : 0] B
  .P(mult_out)  // output wire [5 : 0] P
);
generate if(FULL_ADDER) begin
    c_addsub_0 full_inst (
  .A(A_ff),        // input wire [2 : 0] A
  .B(B_ff),        // input wire [2 : 0] B
  .C_IN(cin_ff),  // input wire C_IN
  .S(add_out)        // output wire [3 : 0] S
);
end
else begin
c_addsub_0 your_instance_name (
  .A(A_ff),        // input wire [2 : 0] A
  .B(B_ff),        // input wire [2 : 0] B
  .C_IN(0),  // input wire C_IN
  .S(add_out)        // output wire [3 : 0] S
);
end 
endgenerate
//the seven_segement counter code from the helping link sent
reg [19:0] refresh_counter; 
// the first 18-bit for creating 2.6ms digit period
// the other 2-bit for creating 4 LED-activating signals
wire [1:0] LED_activating_counter; 
// count        0    ->  1  ->  2  ->  3
// activates    LED1    LED2   LED3   LED4
// and repeat
always @(posedge clk or posedge rst)
begin 
 if(rst)
  refresh_counter <= 0;
 else
  refresh_counter <= refresh_counter + 1;
end 
assign LED_activating_counter = refresh_counter[19:18];
////////////////////////////////////////////////////////////
//the anodes activator code from the helping link
    // anode activating signals for 4 LEDs
    // decoder to generate anode signals 
    reg [3:0] Anode_Activate,LED_BCD;
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD =invalid_case ? E:DASH ;
            // the first hex-digit of the 16-bit number
             end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = invalid_case? 4:DASH;
            // the second hex-digit of the 16-bit number
                end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = invalid_case? 0: out[5:4];
             // the third hex-digit of the 16-bit number
              end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
             LED_BCD = invalid_case?4: out[3:0];
             // the fourth hex-digit of the 16-bit number 
               end   
        default:begin
             Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD =DASH;
            // the first hex-digit of the 16-bit number
            end
        endcase
    end
/////////////////////////////////////////////////////////////////
//The seven segment decoder from the helping link
reg[6:0] LED_out;
// Cathode patterns of the 7-segment LED display 
always @(*)
begin
 case(LED_BCD)
 4'b0000: LED_out = 7'b0000001; // "0"  
 4'b0001: LED_out = 7'b1001111; // "1" 
 4'b0010: LED_out = 7'b0010010; // "2" 
 4'b0011: LED_out = 7'b0000110; // "3" 
 4'b0100: LED_out = 7'b1001100; // "4" 
 4'b0101: LED_out = 7'b0100100; // "5" 
 4'b0110: LED_out = 7'b0100000; // "6" 
 4'b0111: LED_out = 7'b0001111; // "7" 
 4'b1000: LED_out = 7'b0000000; // "8"  
 4'b1001: LED_out = 7'b0000100; // "9" 
 DASH:LED_out=7'B0111111;
 E:LED_out=7'B0000110;
 default: LED_out = 7'b0000001; // "0"
 endcase
end
/////////////////////////////////////////////////
//creating the DFFs for the inputs:
always @(posedge clk ) begin
    A_ff<=A;
end  
always @(posedge clk ) begin
    B_ff<=B;
end 
always @(posedge clk ) begin
    opcode_ff<=opcode;
end 
always @(posedge clk ) begin
    cin_ff<=cin;
end 
always @(posedge clk ) begin
    serial_in_ff<=serial_in;
end 
always @(posedge clk ) begin
    red_op_A_ff<=red_op_A;
end 
always @(posedge clk ) begin
    red_op_B_ff<=red_op_B;
end 
always @(posedge clk ) begin
    bypass_A_ff<=bypass_A;
end 
always @(posedge clk ) begin
    bypass_B_ff<=bypass_B;
end 
always @(posedge clk ) begin
    direction_ff<=direction;
end 
////////////////////////////////////////////////
always @(posedge clk or posedge rst) begin
    if(rst)begin
        out<=0;
        leds_tmp<=0;
    end
    else if((bypass_A_ff&&!bypass_B_ff)||(bypass_A_ff&&(INPUT_PRIORITY=="A")))begin
        out<=A_ff;
        leds_tmp<=0;
    end 
    else if((bypass_B_ff&&!bypass_A_ff)||(bypass_B_ff&&(INPUT_PRIORITY=="B")))begin
        out<=B_ff;
        leds_tmp<=0;
    end
    else if(((red_op_A_ff)&&(red_op_B_ff)&&(!{opcode_ff[2],opcode_ff[1]}))||(opcode_ff==3'b110)||(opcode_ff==3'b111)) begin
        out<=0;
        leds_tmp<=(~(leds_tmp));
    end
    else begin
        casex ({opcode_ff,red_op_A_ff,red_op_B_ff})
        5'b00000:begin
            out<=A_ff&B_ff;
            leds_tmp<=0;
        end
        5'b00010:begin
            out<=&A_ff;
            leds_tmp<=0;
        end
        5'b00001:begin
            out<=&B_ff;
            leds_tmp<=0;
        end
        5'b00011:begin
            if(INPUT_PRIORITY=="A")begin
                out<=&A_ff;
                leds_tmp<=0;
            end
            else if(INPUT_PRIORITY=="B") begin
                out<=&B_ff;
                leds_tmp<=0; 
            end
        end
        5'b00100:begin
            out<=A_ff^B_ff;
            leds_tmp<=0;
        end
        5'b00110:begin
            out<=^A_ff;
            leds_tmp<=0;
        end
        5'b00101:begin
            out<=^B_ff;
            leds_tmp<=0;
        end
        5'b00111:begin
             if(INPUT_PRIORITY=="A")begin
                out<=^A_ff;
                leds_tmp<=0;
            end
            else if(INPUT_PRIORITY=="B") begin
                out<=^B_ff;
                leds_tmp<=0; 
            end
        end
        5'b010xx:begin
           out<=add_out;
            leds_tmp<=0;
        end
        5'b011xx:begin
            out<=mult_out;
            leds_tmp<=0;
        end
        5'b100xx:begin
            if(direction_ff)begin
                out<={out[4:0],serial_in_ff};
            end
            else begin
                out<={serial_in_ff,out[5:1]};
            end
            leds_tmp<=0;
        end
        5'b101xx:begin
            if(direction_ff)begin
                out<={out[4:0],out[5]};
            end
            else begin
                out<={out[0],out[5:1]};
            end
            leds_tmp<=0;
        end
        endcase
    end
end
assign leds=leds_tmp;
endmodule 