//////////////////////////////////////////////////
// Title:   testPr_hdlc
// Author: 
// Date:  
//////////////////////////////////////////////////

/* testPr_hdlc contains the simulation and immediate assertion code of the
   testbench. 

   For this exercise you will write immediate assertions for the Rx module which
   should verify correct values in some of the Rx registers for:
   - Normal behavior
   - Buffer overflow 
   - Aborts

   HINT:
   - A ReadAddress() task is provided, and addresses are documentet in the 
     HDLC Module Design Description
*/

program testPr_hdlc(
  in_hdlc uin_hdlc
);
  
  int TbErrorCnt;
  const int TxSC = 0; // Address 0x0
  const int TxBuff = 1; // Address 0x1
  const int RxSC = 2; // Address 0x2
  const int RxBuff = 3; // Address 0x3
  const int RxLen = 4; // Address 0x4


  /****************************************************************************
   *                                                                          *
   *                               Student code                               *
   *                                                                          *
   ****************************************************************************/

  /********************************************
  *            Specification 1-3              *
  ********************************************/
  // VerifyAbortReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer is zero after abort.
  task VerifyAbortReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    automatic int RXSC_error = 0;
    automatic int RXbuff_error = 0;
 
    ReadAddress(RxSC, ReadData);
    assert (!ReadData [0]) else begin $display("VerifyAbortReceive      FAIL : Rx_Ready bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[1]) else begin $display("VerifyAbortReceive       FAIL : Rx_Drop bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [2]) else begin $display("VerifyAbortReceive      FAIL : Rx_FrameError bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (ReadData [3]) else begin $display("VerifyAbortReceive      FAIL : Rx_AbortSignal bit is not high (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [4]) else begin $display("VerifyAbortReceive      FAIL : Rx_Overflow bit is not low (Immediate assertion)"); RXSC_error++; end

    for (int i = 0; i < Size; i ++) begin
      ReadAddress(RxBuff, ReadData);
      assert (ReadData == 0) else begin $display("VerifyAbortReceive FAIL : Rx data buffer is not zero (Immediate assertion)"); RXbuff_error++; end
    end

    if (!RXSC_error && !RXbuff_error)
      $display("VerifyNormalReceive     PASS : Rx databuffer and Rx_SC contains the correct values (Immediate assertion)");
    else
      TbErrorCnt += (RXSC_error + RXbuff_error);
  endtask

  // VerifyNormalReceive should verify correct value in the Rx status/control
  // register, and that the Rx data buffer contains correct data.
  task VerifyNormalReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    automatic int RXSC_error = 0;
    automatic int RXbuff_error = 0;
    wait(uin_hdlc.Rx_Ready);

    // VERIFY DATA IN RXSC REGISTER
    ReadAddress(RxSC, ReadData);
    assert (ReadData [0]) else begin $display("VerifyNormalReceive     FAIL : Rx_Ready bit is not high (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[1]) else begin $display("VerifyNormalReceive      FAIL : Rx_Drop bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [2]) else begin $display("VerifyNormalReceive     FAIL : Rx_FrameError bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [3]) else begin $display("VerifyNormalReceive     FAIL : Rx_AbortSignal bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [4]) else begin $display("VerifyNormalReceive     FAIL : Rx_Overflow bit is not low (Immediate assertion)"); RXSC_error++; end

    // VERIFY DATA IN RX BUFFER
    for (int i = 0; i < Size; i++) begin
      ReadAddress(RxBuff, ReadData);
      assert (ReadData == data[i]) else begin $display("VerifyNormalReceive     FAIL : Rx data buffer does not contain the correct value (Immediate assertion)"); RXbuff_error++; end
    end

    if (!RXSC_error && !RXbuff_error)
      $display("VerifyNormalReceive     PASS : Rx databuffer and Rx_SC  contains the correct values (Immediate assertion)");
    else
      TbErrorCnt += (RXSC_error + RXbuff_error);
  endtask


  task VerifyOverflowReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    automatic int RXSC_error = 0;
    automatic int RXbuff_error = 0;
    wait(uin_hdlc.Rx_Ready);

    // VERIFY DATA IN RXSC REGISTER
    ReadAddress(RxSC, ReadData);
    assert (ReadData[0]) else begin $display("VerifyOverflowReceive   FAIL : Rx_Ready bit is not high (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[1]) else begin $display("VerifyOverflowReceive   FAIL : Rx_Drop bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[2]) else begin $display("VerifyOverflowReceive   FAIL : Rx_FrameError bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[3]) else begin $display("VerifyOverflowReceive   FAIL : Rx_AbortSignal bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (ReadData[4]) else begin $display("VerifyOverflowReceive   FAIL : Rx_Overflow bit is not high (Immediate assertion)"); RXSC_error++; end

    // VERIFY DATA IN RX BUFFER
    for (int i = 0; i < Size; i++) begin
      ReadAddress(RxBuff, ReadData);
      assert (ReadData == data[i]) else begin $display("VerifyOverflowReceive FAIL : Rx data buffer does not contain the correct value (Immediate assertion)"); RXbuff_error++; end
    end

    if (!RXSC_error && !RXbuff_error)
      $display("VerifyNormalReceive     PASS : Rx databuffer and Rx_SC contain the correct values (Immediate assertion)");
    else
      TbErrorCnt += (RXSC_error + RXbuff_error);
  endtask

  task VerifyDropReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    automatic int RXSC_error = 0;
    automatic int RXbuff_error = 0;

    // VERIFY DATA IN RXSC REGISTER
    ReadAddress(RxSC, ReadData);
    assert (!ReadData[0]) else begin $display("VerifyDropReceive       FAIL : Rx_Ready bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[1]) else begin $display("VerifyDropReceive       FAIL : Rx_Drop bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[2]) else begin $display("VerifyDropReceive       FAIL : Rx_FrameError bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[3]) else begin $display("VerifyDropReceive       FAIL : Rx_AbortSignal bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData[4]) else begin $display("VerifyDropReceive       FAIL : Rx_Overflow bit is not low(Immediate assertion)"); RXSC_error++; end

    // VERIFY DATA IN RX BUFFER
    for (int i = 0; i < Size; i++) begin
      ReadAddress(RxBuff, ReadData);
      assert (ReadData == 0) else begin $display("VerifyDropReceive       FAIL : Rx data buffer is not zero (Immediate assertion)"); RXbuff_error++; end
    end

    if (!RXbuff_error && !RXSC_error)
      $display("VerifyDropReceive       PASS : Rx databuffer and Rx_SC contain the correct values (Immediate assertion)");
    else
      TbErrorCnt += (RXSC_error + RXbuff_error);
  endtask


  task VerifyFrameErrorReceive(logic [127:0][7:0] data, int Size);
    logic [7:0] ReadData;
    automatic int RXSC_error = 0;
    automatic int RXbuff_error = 0;

    // VERIFY DATA IN RXSC REGISTER
    ReadAddress(RxSC, ReadData);
    assert (!ReadData [0]) else begin $display("VerifyFrameErrorReceive FAIL : Rx_Ready bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [1]) else begin $display("VerifyFrameErrorReceive FAIL : Rx_Drop bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (ReadData [2]) else begin $display("VerifyFrameErrorReceive FAIL : Rx_FrameError bit is not high (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [3]) else begin $display("VerifyFrameErrorReceive FAIL : Rx_AbortSignal bit is not low (Immediate assertion)"); RXSC_error++; end
    assert (!ReadData [4]) else begin $display("VerifyFrameErrorReceive FAIL : Rx_Overflow bit is not low (Immediate assertion)"); RXSC_error++; end

    // VERIFY DATA IN RX BUFFER
    for (int i = 0; i < Size; i ++) begin
      ReadAddress(RxBuff, ReadData);
      assert (ReadData == 0) else begin $display("VerifyFrameErrorReceive FAIL : Rx data buffer is not zero (Immediate assertion)"); RXbuff_error++; end
    end

    if (!RXSC_error && !RXbuff_error)
      $display("VerifyFrameErrorReceive PASS : Rx databuffer and Rx_SC contains the correct values (Immediate assertion)");
    else
      TbErrorCnt += RXSC_error + RXbuff_error;
  endtask


  /********************************************
  *            Specification 4               *
  ********************************************/
// Correct TX output according to written TX buffer
  task VerifyNormalTransmit(logic [149:0][7:0] data, int Size, logic [3:0] extra_bits, logic [7:0] extra_bytes);
    logic [7:0] ReadData;
    automatic int Txbuff_error = 0;
    automatic int newSize = Size + extra_bytes;
    automatic int ending_bit;

    for (int i = 0; i < newSize; i++) begin
      if (i == (newSize - 1) && (extra_bits != 0))
        ending_bit = extra_bits;
      else
        ending_bit = 8;

      for (int j = 0; j < ending_bit; j++) begin
        ReadData[j] = uin_hdlc.Tx;
        assert(data[i][j] == uin_hdlc.Tx) else begin $display("VerifyNormalTransmit    FAIL : TX output does not match for written bit[%0d][%0d] (Immediate assertion)", i, j); Txbuff_error++; end;
        @(posedge uin_hdlc.Clk);
      end
    end

    if (!Txbuff_error)
      $display("VerifyNormalTransmit    PASS : TX output is correct according to written TX buffer (Immediate assertion)"); 
    else
      TbErrorCnt += Txbuff_error;
  endtask

  task VerifyAbortTransmit(int Size);
  logic [7:0] ReadData;
  automatic int Txbuff_error = 0;

  for (int i = 0; i < Size; i++) begin
    for (int j = 0; j < 8; j++) begin
      @(posedge uin_hdlc.Clk);
      ReadData[j] = uin_hdlc.Tx;
    end
    assert(ReadData == 8'b11111111) else begin $display("VerifyAbortTransmit     FAIL : TX output does not match for written byte[%0d] (Immediate assertion)", i); Txbuff_error++; end;
  end

  if (!Txbuff_error)
    $display("VerifyAbortTransmit     PASS : TX output is correct according to written TX buffer (Immediate assertion)"); 
  else
    TbErrorCnt += Txbuff_error;
  endtask

  /********************************************
  *            Specification 5               *
  ********************************************/  
  // Start and end of frame pattern generation (Start and end flag: 0111 1110).
  // Currently fixing -J
  task VerifyStartEndFlag(int start);
    logic [7:0] flagsequence;
    logic [7:0] byte_received;
    flagsequence = 8'b01111110;

    if (start)
      wait(!uin_hdlc.Tx && uin_hdlc.Tx_ValidFrame);
    else begin
      wait(!uin_hdlc.Tx_ValidFrame);
      @(posedge(uin_hdlc.Clk));
    end

    for (int i = 0; i < 8; i++) begin
      byte_received[i] = uin_hdlc.Tx;
      @(posedge uin_hdlc.Clk);
    end

    if (start) begin
      assert(byte_received == flagsequence) $display("VerifyStartFlag         PASS : Flagsequence was generated at the start of frame (Immediate assertion)"); 
      else begin $display("VerifyStartFlag         FAIL : Flagsequence was not generated at the start of frame (Immediate assertion)"); 
      TbErrorCnt++; end;
    end
    else begin
      assert(byte_received == flagsequence) $display("VerifyEndFlag           PASS : Flagsequence was generated at the end of frame (Immediate assertion)"); 
      else begin $display("VerifyEndFlag           FAIL : Flagsequence was not generated at the end of frame (Immediate assertion)"); 
      TbErrorCnt++; end; 
    end
  endtask

  /********************************************
  *            Specification 6                *
  ********************************************/
  // Zero insertion and removal for transparent transmission
  task VerifyZeroInsertion(input logic [127:0][7:0] datain, int Size);
    logic [4:0] PrevData;
    automatic int insertion_error = 0;
    PrevData = '0;

    for (int i = 0; i < Size; i++) begin
      for (int j = 0; j < 8; j++) begin
        PrevData[4] = datain[i][j];
        if(&PrevData) begin
          @(posedge uin_hdlc.Clk);
          assert (uin_hdlc.Tx == 1'b0) 
          else begin $display("VerifyZeroInsertion     FAIL : TX output bit was not zero when detecting five 1's (Immediate assertion)"); insertion_error++; end;
          PrevData = PrevData >> 1;
          PrevData[4] = 1'b0;
        end

        @(posedge uin_hdlc.Clk);
        PrevData = PrevData >> 1;
      end
    end

    if (!insertion_error)
      $display("VerifyZeroInsertion     PASS : TX output bit was zero when detecting five 1's (Immediate assertion)"); 
    else
      TbErrorCnt += insertion_error;
  endtask

  /********************************************
  *            Specification 7               *
  ********************************************/  
  // Idle pattern generation and checking (1111 1111 when not operating).
  // or should this be a concurrent assertion? 
  task VerifyIdleSequence();
    logic [7:0] idlesequence;
    logic [7:0] byte_received;
    idlesequence = 8'b11111111;

    for (int i = 0; i < 8; i++) begin
      @(posedge uin_hdlc.Clk);
      byte_received[i] = uin_hdlc.Tx;
    end

    assert(byte_received == idlesequence) $display("VerifyIdleSequence      PASS : Idlesequence was generated when the controller is unoperating (Immediate assertion)"); 
                                    else begin $display("VerifyIdleSequence      FAIL : Idlesequence was not generated when the controller is unoperating (Immediate assertion)"); 
                                    TbErrorCnt++; end;
  endtask


  /********************************************
  *            Specification 8               *
  ********************************************/  
  // Abort pattern generation and checking (1111 1110). Remember that the 0 must be sent first.
  task VerifyAbortSequence();
    logic [7:0] abortsequence;
    logic [7:0] byte_received;
    logic [7:0] reading;
    abortsequence = 8'b11111110;

    wait(uin_hdlc.Tx_AbortedTrans && uin_hdlc.Tx_FCSDone && !uin_hdlc.Tx_DataAvail);
    for (int i = 0; i < 8; i++) begin
      @(posedge uin_hdlc.Clk);
      byte_received[i] = uin_hdlc.Tx;
    end

    assert(byte_received == abortsequence) $display("VerifyAbortSequence     PASS : Abortsequence was generated when aborting transmission (Immediate assertion)"); 
                                    else begin $display("VerifyAbortSequence     FAIL : Abortsequence was not generated when aborting transmission (Immediate assertion)"); 
                                    TbErrorCnt++; end;
  endtask


  /********************************************
  *            Specification 9                *
  ********************************************/  
  // Concurrent assertion

  /********************************************
  *            Specification 10               *
  ********************************************/  
  // Concurrent assertion

  /********************************************
  *            Specification 11               *
  ********************************************/  
  // In progress
  task VerifyFCSTransmit(logic [23:0] data, logic [3:0] extra_bits);
    logic [7:0] ReadData;
    automatic int Txbuff_error = 0;
    automatic int newSize = 16 + extra_bits;
    automatic int ending_bit;

    for (int i = 0; i < newSize; i++) begin
      assert(data[i] == uin_hdlc.Tx) 
      else begin $display("VerifyFCSTransmit       FAIL : FCS output does not match for written bit[%0d] (Immediate assertion)", i); Txbuff_error++; end;
      @(posedge uin_hdlc.Clk);
    end


    if (!Txbuff_error)
      $display("VerifyFCSTransmit       PASS : FCS output is correct according to generated FCS bytes (Immediate assertion)"); 
    else
      TbErrorCnt += Txbuff_error;
  endtask


  /********************************************
  *            Specification 12               *
  ********************************************/  
  // Concurrent assertion


  /********************************************
  *            Specification 13               *
  ********************************************/  
  // Concurrent assertion


    /********************************************
  *            Specification 14               *
  ********************************************/  
  // Rx FrameSize should equal the number of bytes received in a frame (max. 126 bytes =128 bytes in buffer – 2 FCS bytes)
  task VerifyFrameSize();
    logic [7:0] ReadData;

    ReadAddress(RxLen, ReadData);
    assert (ReadData == uin_hdlc.Rx_FrameSize) $display("VerifyFrameSize         PASS : Rx_FrameSize equals the number of bytes received in a frame (Immediate assertion)"); 
    else begin $display("VerifyFrameSize         FAIL : Rx_FrameSize does not equal the number of bytes received in a frame (Immediate assertion)"); TbErrorCnt++; end;
  endtask


  /********************************************
  *            Specification 15               *
  ********************************************/  
  // Concurrent assertion

  /********************************************
  *            Specification 16               *
  ********************************************/  
  // Concurrent assertion

  
  /********************************************
  *            Specification 17               *
  ********************************************/  
  // Concurrent assertion


  /********************************************
  *            Specification 18               *
  ********************************************/  
  task VerifyTxFull(int Size);
    logic [7:0] MAX_SIZE;
    MAX_SIZE = 8'h7E;
    //$display("checking if %0d > %0d...", Size, MAX_SIZE); // for debugging
    
    if (Size > MAX_SIZE)
      assert(uin_hdlc.Tx_Full == 1'b1) $display ("VerifyTxFull            PASS : Tx_Full was asserted after writing 126 or more bytes to the TX buffer (Immediate assertion)"); 
      else begin $display("VerifyTxFull            FAIL : Tx_Full was not asserted after writing 126 or more bytes to the TX buffer (Immediate assertion)"); TbErrorCnt++; end
  endtask 



  /****************************************************************************
   *                                                                          *
   *                             Simulation code                              *
   *                                                                          *
   ****************************************************************************/

  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    Init();

    //Receive: Size, Abort, FCSerr, NonByteAligned, Overflow, Drop, SkipRead
    Receive($urandom_range(126, 0), 0, 0, 0, 0, 0, 0); //Normal
    Receive($urandom_range(126, 0), 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive($urandom_range(126, 0), 0, 0, 0, 0, 0, 0); //Normal
    Receive($urandom_range(126, 0), 1, 0, 0, 0, 0, 0); //Abort
    Receive(126, 0, 0, 0, 1, 0, 0); //Overflow
    Receive($urandom_range(126, 0), 0, 0, 0, 0, 0, 0); //Normal
    Receive($urandom_range(126, 0), 0, 1, 0, 0, 0, 0); //FCSError
    Receive($urandom_range(126, 0), 0, 0, 0, 0, 1, 0); //Drop

    

    Transmit($urandom_range(126, 0), 0); // Normal
    Transmit($urandom_range(126, 0), 0); // Normal 
    Transmit($urandom_range(126, 0), 0); // Normal
    Transmit(126, 0); // Normal
    Transmit($urandom_range(126, 0), 1); // Abort

    $display("*************************************************************");
    $display("%t - Finishing Test Program", $time);
    $display("*************************************************************");
    $stop;
  end

  final begin

    $display("**************************************************************");
    $display("*                               *                            *");
    $display("* \tAssertion Errors: %0d\t  * \tCoverage: %0.2f %%      *", TbErrorCnt + uin_hdlc.ErrCntAssertions, gr22_cg.get_inst_coverage());
    $display("*                               *                            *");
    $display("**************************************************************");

  end

  task Init();
    uin_hdlc.Clk         =   1'b0;
    uin_hdlc.Rst         =   1'b0;
    uin_hdlc.Address     = 3'b000;
    uin_hdlc.WriteEnable =   1'b0;
    uin_hdlc.ReadEnable  =   1'b0;
    uin_hdlc.DataIn      =     '0;
    uin_hdlc.TxEN        =   1'b1;
    uin_hdlc.Rx          =   1'b1;
    uin_hdlc.RxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
  endtask

  task WriteAddress(input logic [2:0] Address, input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.WriteEnable = 1'b0;
  endtask

  task ReadAddress(input logic [2:0] Address ,output logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address    = Address;
    uin_hdlc.ReadEnable = 1'b1;
    #100ns;
    Data                = uin_hdlc.DataOut;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.ReadEnable = 1'b0;
  endtask

  task InsertFlagOrAbort(int flag);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    if(flag)
      uin_hdlc.Rx = 1'b0;
    else
      uin_hdlc.Rx = 1'b1;
  endtask

  task MakeRxStimulus(logic [127:0][7:0] Data, int Size);
    logic [4:0] PrevData;
    PrevData = '0;
    for (int i = 0; i < Size; i++) begin
      for (int j = 0; j < 8; j++) begin
        if(&PrevData) begin
          @(posedge uin_hdlc.Clk);
          uin_hdlc.Rx = 1'b0;
          PrevData = PrevData >> 1;
          PrevData[4] = 1'b0;
        end

        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = Data[i][j];

        PrevData = PrevData >> 1;
        PrevData[4] = Data[i][j];
      end
    end
  endtask


  task ComputeExtraBits(logic [7:0] zeros_inserted, output logic [3:0] extra_bits, output logic [7:0] extra_bytes); 
    automatic int exceeding_byte;
    automatic int totalbits;
    extra_bits = zeros_inserted % 8;
    extra_bytes = zeros_inserted / 8;
    
    if (extra_bits != 0)
      extra_bytes += 1;
  endtask

  task ZeroInsertion(input logic [127:0][7:0] datain, input logic [15:0] FCSBytes, int FCSorMessage, int Size, 
  output logic[149:0][7:0] zeroinserted_data, output logic [23:0] zeroinserted_FCS, output logic [7:0] zeros_inserted);
    static int count;
    automatic int old_i = 0;
    automatic int old_j = 0;
    automatic int FCS_index = 0;
    automatic int extra_Size = 0;
    zeros_inserted = 0;
    zeroinserted_data = 0;

    if (!FCSorMessage) begin
      count = 0;
      for (int i = 0; i < 150; i++) begin
        for (int j = 0; j < 8; j++) begin
          if (count == 5) begin
            count = 0;
            zeroinserted_data[i][j] = 1'b0;
            zeros_inserted++;
          end
          else if (datain[old_i][old_j] == 1'b1) begin
            zeroinserted_data[i][j] = datain[old_i][old_j];
            if (old_j < 7)
              old_j++;
            else begin
              old_j = 0;
              old_i++;
            end
            count++;
          end
          else begin
            zeroinserted_data[i][j] = datain[old_i][old_j];
            count = 0;
            if (old_j < 7)
              old_j++;
            else begin
              old_j = 0;
              old_i++;
            end
          end
        end
      end
    end
    else begin
      old_i = 0;
      zeros_inserted = 0;
      for (int i = 0; i < 24; i++) begin
        if (count == 5) begin
          count = 0;
          zeroinserted_FCS[i] = 1'b0;
          zeros_inserted++;
        end
        else if (FCSBytes[i] == 1'b1) begin
          zeroinserted_FCS[i] = FCSBytes[old_i];
          count++;
          old_i++;
        end
        else begin
          zeroinserted_FCS[i] = FCSBytes[old_i];
          count = 0;
          old_i++;
        end
      end
    end
  endtask


  task Transmit(int Size, int Abort);
    logic [127:0][7:0] TransmitData;
    logic [149:0][7:0] zeroinserted_data;
    logic [23:0] zeroinserted_FCS;
    logic [15:0] FCSBytes;
    logic [7:0] zeros_inserted, extra_bytes;
    logic [3:0] extra_bits;
    string msg;

    if(Abort)
      msg = "- Abort";
    else
      msg = "- Normal";
    $display("*************************************************************");
    $display("%t - Starting task Transmit with messageSize %0d %s", $time, Size, msg);
    $display("*************************************************************");

    TransmitData = 'x;

    for (int i = 0; i < Size; i++) begin
        TransmitData[i] = $urandom;
    end


    ZeroInsertion(TransmitData, FCSBytes, 0, Size, zeroinserted_data, zeroinserted_FCS, zeros_inserted); // Replicate the zero insertion
    ComputeExtraBits(zeros_inserted, extra_bits, extra_bytes);

    TransmitData[Size]   = '0;
    TransmitData[Size+1] = '0;

    GenerateFCSBytes(TransmitData, Size, FCSBytes);

    VerifyIdleSequence();
    
    wait(uin_hdlc.Tx_Done);
    for (int i = 0; i < Size; i++) begin
        WriteAddress(TxBuff, TransmitData[i]);
    end

    VerifyTxFull(Size);
  
    WriteAddress(TxSC, 8'h02); // Set enable bit in SC_TX register, starts transmission of data from buffer

    VerifyStartEndFlag(1);
    
    if (Abort) begin
      WriteAddress(TxSC, 8'h04);
      VerifyAbortSequence();
      VerifyAbortTransmit(Size);
    end
    else begin
      fork 
        begin
          VerifyZeroInsertion(TransmitData, Size);
        end
        begin
          VerifyNormalTransmit(zeroinserted_data, Size, extra_bits, extra_bytes);
          ZeroInsertion(TransmitData, FCSBytes, 1, Size, zeroinserted_data, zeroinserted_FCS, zeros_inserted);
          ComputeExtraBits(zeros_inserted, extra_bits, extra_bytes);
          VerifyFCSTransmit(zeroinserted_FCS, extra_bits);
        end
        begin
          VerifyStartEndFlag(0);
        end
      join
    end

    repeat(8) 
      @(posedge uin_hdlc.Clk);
    
  endtask


  task Receive(int Size, int Abort, int FCSerr, int NonByteAligned, int Overflow, int Drop, int SkipRead);
    logic [127:0][7:0] ReceiveData;
    logic       [15:0] FCSBytes;
    logic   [2:0][7:0] OverflowData;
    string msg;
    
    if(Abort)
      msg = "- Abort";
    else if(FCSerr)
      msg = "- FCS error";
    else if(NonByteAligned)
      msg = "- Non-byte aligned";
    else if(Overflow)
      msg = "- Overflow";
    else if(Drop)
      msg = "- Drop";
    else if(SkipRead)
      msg = "- Skip read";
    else
      msg = "- Normal";
    $display("*************************************************************");
    $display("%t - Starting task Receive with messageSize %0d %s", $time, Size, msg);
    $display("*************************************************************");

    for (int i = 0; i < Size; i++) begin
      ReceiveData[i] = $urandom;
    end
    ReceiveData[Size]   = '0;
    ReceiveData[Size+1] = '0;

    //Calculate FCS bits;
    GenerateFCSBytes(ReceiveData, Size, FCSBytes);
    if (!FCSerr) // Added condition -J
      ReceiveData[Size]   = FCSBytes[7:0];
      ReceiveData[Size+1] = FCSBytes[15:8];

    //Enable FCS
    if(!Overflow && !NonByteAligned)
      WriteAddress(RxSC, 8'h20); 
    else
      WriteAddress(RxSC, 8'h00);

    //Generate stimulus
    InsertFlagOrAbort(1);
    
    MakeRxStimulus(ReceiveData, Size + 2);
    
    if(Overflow) begin
      OverflowData[0] = 8'h44;
      OverflowData[1] = 8'hBB;
      OverflowData[2] = 8'hCC;
      MakeRxStimulus(OverflowData, 3);
    end

    if(Abort) begin
      InsertFlagOrAbort(0);
    end else begin
      InsertFlagOrAbort(1);
    end
    

    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;

    repeat(8)
      @(posedge uin_hdlc.Clk);

    if (!FCSerr)
      VerifyFrameSize();

    if(Abort)
      VerifyAbortReceive(ReceiveData, Size);
    else if(Overflow)
      VerifyOverflowReceive(ReceiveData, Size);
    else if (FCSerr)
      VerifyFrameErrorReceive(ReceiveData, Size);
    else if (Drop) begin
      WriteAddress(RxSC, 8'h02);
      VerifyDropReceive(ReceiveData, Size);
    end
    else if(!SkipRead)
      VerifyNormalReceive(ReceiveData, Size);

    #5000ns;
  endtask

  task GenerateFCSBytes(logic [127:0][7:0] data, int size, output logic[15:0] FCSBytes);
    logic [23:0] CheckReg;
    CheckReg[15:8]  = data[1];
    CheckReg[7:0]   = data[0];
    for(int i = 2; i < size+2; i++) begin
      CheckReg[23:16] = data[i];
      for(int j = 0; j < 8; j++) begin
        if(CheckReg[0]) begin
          CheckReg[0]    = CheckReg[0] ^ 1;
          CheckReg[1]    = CheckReg[1] ^ 1;
          CheckReg[13:2] = CheckReg[13:2];
          CheckReg[14]   = CheckReg[14] ^ 1;
          CheckReg[15]   = CheckReg[15];
          CheckReg[16]   = CheckReg[16] ^1;
        end
        CheckReg = CheckReg >> 1;
      end
    end
    FCSBytes = CheckReg;
  endtask

covergroup hdlcproject_cg() @(posedge uin_hdlc.Clk);
  Rx_AbortSignal : coverpoint uin_hdlc.Rx_AbortSignal {
    bins No_RxAbort = {0};
    bins RxAbort = {1};
  }
  Rx_FCSen : coverpoint uin_hdlc.Rx_FCSen {
    bins No_RxFCSen = {0};
    bins RxFCSen = {1};
  }
  Rx_FCSerr : coverpoint uin_hdlc.Rx_FCSerr {
    bins No_RxFCSerr = {0};
    bins RxFCSerr = {1};
  }
  Rx_FrameError : coverpoint uin_hdlc.Rx_FrameError {
    bins No_RxFrameError = {0};
    bins RxFrameError = {1};
  }
  Rx_Overflow : coverpoint uin_hdlc.Rx_Overflow {
    bins No_RxOverflow = {0};
    bins RxOverflow = {1};
  }
  Rx_Ready : coverpoint uin_hdlc.Rx_Ready {
    bins No_RxReady = {0};
    bins RxReady = {1};
  }
  Rx_Drop : coverpoint uin_hdlc.Rx_Drop {
    bins No_RxDrop = {0};
    bins RxDrop = {1};
  }
  Rx_ValidFrame : coverpoint uin_hdlc.Rx_ValidFrame {
    bins No_RxValidFrame = {0};
    bins RxValidFrame = {1};
  }
  Rx_EoF : coverpoint uin_hdlc.Rx_EoF {
    bins No_RxEoF = {0};
    bins RxEoF = {1};
  }
  Rx_FrameSize : coverpoint uin_hdlc.Rx_FrameSize {
    bins RxFrameSize[] = {[0:126]};
  }
  Rx_FlagDetect : coverpoint uin_hdlc.Rx_FlagDetect {
    bins No_RxFlagDetect = {0};
    bins RxFlagDetect = {1};
  }
  Tx_Full : coverpoint uin_hdlc.Tx_Full {
    bins No_TxFull = {0};
    bins TxFull = {1};
  }
  Tx_AbortedTrans : coverpoint uin_hdlc.Tx_AbortedTrans {
    bins No_TxAbortedTrans = {0};
    bins TxAbortedTrans = {1};
  }
  Tx_AbortFrame : coverpoint uin_hdlc.Tx_AbortFrame {
    bins No_TxAbortFrame = {0};
    bins TxAbortFrame = {1};
  }
  Tx_Done : coverpoint uin_hdlc.Tx_Done {
    bins No_TxDone = {0};
    bins TxDone = {1};
  }
  Tx_Enable : coverpoint uin_hdlc.Tx_Enable {
    bins No_TxEnable = {0};
    bins TxEnable = {1};
  }
  Tx_DataAvail : coverpoint uin_hdlc.Tx_DataAvail {
    bins No_TxDataAvail = {0};
    bins TxDataAvail = {1};
  }
  Tx_ValidFrame : coverpoint uin_hdlc.Tx_ValidFrame {
    bins No_TxValidFrame = {0};
    bins TxValidFrame = {1};
  }
  Tx_FCSDone : coverpoint uin_hdlc.Tx_FCSDone {
    bins No_TxFCSDone = {0};
    bins TxFCSDone = {1};
  }
  DataIn : coverpoint uin_hdlc.DataIn {
    bins datain[] = {[0:127]};
  }
  DataOut : coverpoint uin_hdlc.DataOut {
    bins dataout[] = {[0:127]};
  }
endgroup

hdlcproject_cg gr22_cg = new();

endprogram
