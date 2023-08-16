module alsutb ();
parameter A_INPUT_PRIORITY="A";
parameter B_INPUT_PRIORITY="B";
parameter FULL_ADDER="ON";
parameter NO_FULL_ADDER="OFF";
reg clk,rst,cin,serial_in,red_op_A,red_op_B,bypass_A,bypass_B,direction;
reg [2:0] A,B,opcode;
wire [15:0] full_A_leds, full_B_leds, half_A_leds, half_B_leds;
wire [5:0] full_A_out, full_B_out, half_A_out, half_B_out;
ALSU #(.INPUT_PRIORITY(A_INPUT_PRIORITY),.FULL_ADDER(FULL_ADDER)) full_A(.clk(clk),.rst(rst),.A(A),.B(B),.cin(cin),.opcode(opcode),.serial_in(serial_in),.red_op_A(red_op_A),.red_op_B(red_op_B),.bypass_A(bypass_A),.bypass_B(bypass_B),.direction(direction),.out(full_A_out),.leds(full_A_leds));
ALSU #(.INPUT_PRIORITY(B_INPUT_PRIORITY),.FULL_ADDER(FULL_ADDER)) full_B(.clk(clk),.rst(rst),.A(A),.B(B),.cin(cin),.opcode(opcode),.serial_in(serial_in),.red_op_A(red_op_A),.red_op_B(red_op_B),.bypass_A(bypass_A),.bypass_B(bypass_B),.direction(direction),.out(full_B_out),.leds(full_B_leds));
ALSU #(.INPUT_PRIORITY(A_INPUT_PRIORITY),.FULL_ADDER(NO_FULL_ADDER)) half_A(.clk(clk),.rst(rst),.A(A),.B(B),.cin(cin),.opcode(opcode),.serial_in(serial_in),.red_op_A(red_op_A),.red_op_B(red_op_B),.bypass_A(bypass_A),.bypass_B(bypass_B),.direction(direction),.out(half_A_out),.leds(half_A_leds));
ALSU #(.INPUT_PRIORITY(B_INPUT_PRIORITY),.FULL_ADDER(NO_FULL_ADDER)) half_B(.clk(clk),.rst(rst),.A(A),.B(B),.cin(cin),.opcode(opcode),.serial_in(serial_in),.red_op_A(red_op_A),.red_op_B(red_op_B),.bypass_A(bypass_A),.bypass_B(bypass_B),.direction(direction),.out(half_B_out),.leds(half_B_leds));
initial begin
    clk=0;
    forever begin
        #30 clk=~clk;
    end
end
initial begin
    rst=1;
    repeat(2)@(negedge clk);
    repeat(100)begin
        A=$random;
        B=$random;
        cin=$random;
        serial_in=$random;
        red_op_A=$random;
        red_op_B=$random;
        bypass_A=$random;
        bypass_B=$random;
        direction=$random;
        opcode=$urandom_range(0,7);
        @(negedge clk);
    end
    rst=0;
    repeat(700)begin
       A=$random;
        B=$random;
        cin=$random;
        serial_in=$random;
        red_op_A=$random;
        red_op_B=$random;
        bypass_A=$random;
        bypass_B=$random;
        direction=$random;
        opcode=$urandom_range(0,7);
        @(negedge clk); 
    end
    $stop;
end
endmodule 