//////////////////////////////////////////////////
// Title:   assertions_hdlc
// Author:  
// Date:    
//////////////////////////////////////////////////

/* The assertions_hdlc module is a test module containing the concurrent
   assertions. It is used by binding the signals of assertions_hdlc to the
   corresponding signals in the test_hdlc testbench. This is already done in
   bind_hdlc.sv 

   For this exercise you will write concurrent assertions for the Rx module:
   - Verify that Rx_FlagDetect is asserted two cycles after a flag is received
   - Verify that Rx_AbortSignal is asserted after receiving an abort flag
*/

module assertions_hdlc (
  output int   ErrCntAssertions,
  input  logic Clk,
  input  logic Rst,
  input  logic Rx,
  input  logic Rx_FlagDetect,
  input  logic Rx_ValidFrame,
  input  logic Rx_AbortDetect,
  input  logic Rx_AbortSignal,
  input  logic Rx_Overflow,
  input  logic Rx_WrBuff,
  input logic Rx_EoF,
  input logic [7:0] Rx_FrameSize,
  input logic Rx_Ready,
  input logic Rx_NewByte,
  input logic Rx_FrameError,
  input logic Rx_FCSerr,
  input logic Rx_FCSen,
  input logic Tx,
  input logic Tx_ValidFrame,
  input logic Tx_AbortFrame,
  input logic Tx_AbortedTrans,
  input logic Tx_WrBuff,
  input logic Tx_DataAvail,
  input logic Tx_Done,
  input logic Tx_NewByte,
  input logic Tx_Enable,
  input logic Tx_FCSDone,
  input logic Tx_Full
);

  initial begin
    ErrCntAssertions  =  0;
  end

   /*******************************************
   *                Sequences                 *
   *******************************************/

  sequence Rx_flag;
    !Rx ##1 Rx [*6] ##1 !Rx; //01111110 
  endsequence

  sequence Rx_Abortdetect;
    !Rx ##1 Rx [*7]; // 11111110 
  endsequence

  sequence idle_sequence;
    Tx [*8];
  endsequence

  sequence Tx_Abortdetect;
    !Tx ##1 Tx [*7];
  endsequence

  sequence Rx_NewByteSeq;
    ($rose(Rx_NewByte))[->129]; 
  endsequence


   /*******************************************
   *                Properties                *
   *******************************************/

  /********************************************
  *                From part A                *
  ********************************************/
  property RX_FlagDetect;
    @(posedge Clk) disable iff(!Rst) Rx_flag |-> ##2 Rx_FlagDetect;
  endproperty


  /********************************************
  *                   part B                  *
  ********************************************/


  /********************************************
  *              Specification 7              *
  ********************************************/
  // WRONG -ATTEMPT
  /*
  property idle_transmission;
    @(posedge Clk) !Tx_ValidFrame && !Tx_AbortedTrans |-> idle_sequence;
  endproperty
  */


  /********************************************
  *              Specification 8              *
  ********************************************/
  // Abort pattern generation and checking (1111 1110). Remember that the 0 must be sent first.
  // Also an immediate assertion for this.
  property Tx_AbortSequence;
    @(posedge Clk) disable iff(!Rst) $rose(Tx_AbortedTrans) |-> ##2 Tx_Abortdetect;
  endproperty

  /********************************************
  *              Specification 9              *
  ********************************************/
  //  When aborting frame during transmission, Tx AbortedTrans should be asserted.
  property TX_AbortFrame;
    @(posedge Clk) disable iff (!Rst) Tx_AbortFrame |-> ##2 $rose(Tx_AbortedTrans);
  endproperty
  

  /********************************************
  *             Specification 10              *
  ********************************************/
  // Abort pattern detected during valid frame should generate Rx AbortSignal.
  property RX_AbortSignal;
    @(posedge Clk) disable iff(!Rst) Rx_Abortdetect ##0 Rx_ValidFrame |=> ##2 Rx_AbortSignal;
  endproperty

  /********************************************
  *             Specification 12              *
  ********************************************/
  // When a whole RX frame has been received, check if end of frame is generated | working fine! but have confusion for overflow   -T
  property EndOfFrame;
    @(posedge Clk) disable iff(!Rst)  $fell(Rx_ValidFrame) |=> $rose(Rx_EoF);
  endproperty

  /********************************************
  *            Specification 13               *
  ********************************************/
  // When receiving more than 128 bytes, Rx Overflow should be asserted | Not complete -J
  property Rxbuffer_Overflow;
    @(posedge Clk) disable iff (!Rst || !Rx_ValidFrame) $rose(Rx_ValidFrame) ##0 Rx_NewByteSeq |=> $rose(Rx_Overflow);
  endproperty

  /********************************************
  *            Specification 15               *
  ********************************************/
  //if Rx_Ready is high,, Rx_buffer need to be ready to read
  property ReadyCheck;
    @(posedge Clk) disable iff(!Rst) $rose(Rx_Ready) |=>$past(Rx_EoF);
  endproperty
  RX_Ready_Assert : assert property (ReadyCheck) else begin 
    $display("RX_Ready FAIL (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end


  /********************************************
  *            Specification 16               *
  ********************************************/
  // Non-byte aligned data or error in FCS checking should result in frame error
  property RX_FrameError;
    @(posedge Clk) disable iff (!Rst) Rx_FCSerr && Rx_FCSen |=> $rose(Rx_FrameError);
  endproperty
  

  //flag need to be detected at the end of new byte,, not on the half way of new byte ... Currently no stimulus for nonbytealign, so unable to verify....
  property byte_alignment;
    @(posedge Clk) disable iff (!Rst) 
    Rx_ValidFrame && Rx_FlagDetect && !(Rx_NewByte) |-> Rx_FrameError;
  endproperty

  /********************************************
  *            Specification 17               *
  ********************************************/
  // Tx Done should be asserted when the entire TX buffer has been read for transmission.
  property TxbufferDone;
    @(posedge Clk) disable iff (!Rst) $fell(Tx_DataAvail) |-> Tx_Done;
  endproperty

  /********************************************
  *               Assertions                  *
  ********************************************/
  TX_AbortFrame_Assert : assert property (TX_AbortFrame) begin
    $display("TX_AbortFrame           PASS : Tx_AbortedTrans went high after Tx_AbortFrame (Concurrent assertion)");
  end else begin 
    $display("TX_AbortFrame           FAIL : Tx_AbortedTrans did not go high after Tx_AbortFrame (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end

  Tx_AbortSequence_Assert : assert property (Tx_AbortSequence) $display("Tx_AbortSequence        PASS : Abortsequence was generated when aborting transmission (Concurrent assertion)");  
  else begin $display("Tx_AbortSequence       FAIL: Abortsequence was not generated when aborting transmission (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end
  
  RX_AbortSignal_Assert : assert property (RX_AbortSignal) begin
    $display("RX_AbortSignal          PASS : Rx_AbortSignal was asserted after detecting an abort pattern during valid frame (Concurrent assertion)");
  end else begin 
    $display("RX_AbortSignal          FAIL : Rx_AbortSignal was not asserted after detecting an abort pattern during valid frame (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end

  
  EndOfFrame_Assert : assert property (EndOfFrame) begin
    $display("EndOfFrame              PASS : EOF signal was asserted when a whole RX frame was received (Concurrent assertion)");
  end else begin
    $display("EndOfFrame              FAIL : EoF signal was not asserted when a whole RX frame was received (Concurrent assertion)");
    ErrCntAssertions++;
  end


  Rxbuffer_Overflow_Assert : assert property (Rxbuffer_Overflow) begin
    $display("Rxbuffer_Overflow       PASS : Rx_Overflow was asserted when receiving more than 128 bytes (Concurrent assertion)");
  end else begin
    $display("Rxbuffer_Overflow       FAIL : Rx_Overflow was not asserted when receiving more than 128 bytes (Concurrent assertion)");
    ErrCntAssertions++;
  end

  RX_FrameError_Assert : assert property (RX_FrameError) begin
    $display("RX_FrameError           PASS : Rx_FrameError was asserted when an error in FCS was detected (Concurrent assertion)");
  end else begin 
    $display("RX_FrameError           FAIL : Rx_FrameError was not asserted when an error in FCS was detected (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end
  
  TxbufferDone_Assert : assert property (TxbufferDone) begin
    $display("TxbufferDone            PASS : Tx_Done was asserted when the entire TX buffer had been read for transmission (Concurrent assertion)");
  end else begin 
    $display("TxbufferDone            FAIL : Tx_Done was not asserted when the entire TX buffer had been read for transmission (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end



  /*************************************
             From Part A
  *************************************/
    /*
  RX_FlagDetect_Assert : assert property (RX_FlagDetect) begin
    $display("RX_FlagDetect           PASS : Rx_FlagDetect was asserted after a flag sequence (Concurrent assertion)");
  end else begin 
    $display("RX_FlagDetect           FAIL : Rx_FlagDetect was not asserted after a flag sequence (Concurrent assertion)"); 
    ErrCntAssertions++; 
  end
  */



  /*************************************
             Failed Attempts
  *************************************/

    /*
  idletransmission_Assert : assert property (idle_transmission)
    //$display("PASS : idle_transmission");
  //end 
    else begin
    $display("The idle pattern (11111111) was not generated when the controller is unoperating");
    ErrCntAssertions++;
    end
  */
  /*
  sequence fiveones;
    Tx [*5];
  endsequence

  sequence fivevalidframes;
    Tx_ValidFrame [*5];
  endsequence

  property Tx_ZeroInsertion;
  @(posedge Clk) disable iff(!Rst) fiveones and fivevalidframes |=> !Tx;
  endproperty

  Tx_ZeroInsertion_Assert : assert property (Tx_ZeroInsertion) $display("Tx_ZeroInsertion        PASS");  else begin 
  $display("Tx_ZeroInsertion        FAIL"); 
  ErrCntAssertions++; 
  end
  */

   /* RX_byte_alignment : assert property (byte_alignment) begin
    $display("RX_FrameError           PASS : Rx_FrameError was asserted when byte isnt aligned");
  end else begin 
    $display("RX_FrameError           FAIL : Rx_FrameError was not asserted when byte isnt aligned"); 
    ErrCntAssertions++; 
  end
  */


endmodule
