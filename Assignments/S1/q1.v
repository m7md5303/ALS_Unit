module cir1(A,B,C,D,E,F,sel,out,out_bar);
input  A,B,C,D,E,F,sel;
output out,out_bar;
wire n1,n2;
assign n1=A&B&C;
assign n2=D^E~^F;
assign out=(sel==1'b1)? n2:n1;
assign out_bar=~out;  
endmodule


