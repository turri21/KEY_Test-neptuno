//===========================================================================
// KEY_Test
// Description: Detect the 2 buttons KEY1~KEY2 on the development board. 
// When the button is detected to be pressed, the LED light turns off.
//===========================================================================
`timescale 1ns / 1ps
module neptuno_top  (
	clk,    // Input clock on development board: 50Mhz
	rst_n,  // Enter the reset button on the development board
	key_in, // Input key signal(KEY1~KEY2)
	led     // Output LED light, used to control the LED on the dev board
);

//===========================================================================
// PORT declarations
//===========================================================================						
input        clk; 
input        rst_n;
input  [1:0] key_in;
output 		 led;

//Register definition
reg [19:0] count;
reg [1:0] key_scan; //Key scan value KEY

//===========================================================================
// Sampling key values, scanning once every 20ms, the sampling frequency is 
// less than the key glitch frequency, which is equivalent to filtering out 
// high-frequency glitch signals.
//===========================================================================
always @(posedge clk or negedge rst_n)     //Detect the rising edge of clock 
                                           //and the falling edge of reset
begin
   if(!rst_n)                //Reset signal is active low
      count <= 20'd0;        //Counter cleared to 0
   else
      begin
         if(count ==20'd999_999) //Scan a button in 20ms, 
                                 //count in 20ms (50M/50-1=999_999)
            begin
               count <= 20'b0;     //The counter counts to 20ms and the counter is cleared.
               key_scan <= key_in; //Sampling button input level
            end
         else
            count <= count + 20'b1; //Counter increments by 1
     end
end
//===========================================================================
// The key signal is latched for one clock beat
//===========================================================================
reg [1:0] key_scan_r;
always @(posedge clk)
    key_scan_r <= key_scan;       

//When a falling edge change is detected on a key, it means that the key is 
//pressed and the key is valid.    
wire [1:0] flag_key = key_scan_r[1:0] & (~key_scan[1:0]);  

//===========================================================================
// LED light control, when the button is pressed, the relevant LED output 
// flips
//===========================================================================
reg temp_led;
always @ (posedge clk or negedge rst_n)      //Detect the rising edge of clock 
                                             //and the falling edge of reset
begin
    if (!rst_n)                 //Reset signal is active low
         temp_led <= 1'b1;   	//The LED light control signal output is low, 
                                //and the LED light goes out
    else
         begin            
             if ( flag_key[0] ) temp_led <= ~temp_led;  //When the key KEY1 value changes, 
                                                        //the LED will flip on and off.
             if ( flag_key[1] ) temp_led <= ~temp_led;  //When the key KEY2 value changes, 
                                                        //the LED will flip on and off.
         end
end
 
 assign led = temp_led;

endmodule

