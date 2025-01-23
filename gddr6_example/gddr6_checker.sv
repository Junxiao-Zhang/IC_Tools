module gddr6_checker(
    input           		CLK,
    input  CLKB,
input           		WCLK0, 
input WCLK0B, 
input WCLK1, 
input WCLK1B,
input           		CKEB, 
input CABIB,
input   [`ADDREA-1:0]   CA,
inout   [`BIT_DQ]  		DQ,
inout   [`nDBI-1:0]  	DBIB,
inout   [`nEDC-1:0]  	EDC,

input           		RESETB

);
    
endmodule