//-----------------------------------------------
// Space Cubics Cortex-M3 SubSystem
//  Cortex-M3 Exclusive Monitor
//  Module: sc_cm3_ex_mon
//-----------------------------------------------
// Copyright © 2022 Space Cubics, LLC.
//-----------------------------------------------

module sc_cm3_ex_mon (
  // System Interface
  input HCLK,
  input HRESETN,

  // Exclusive Monitor AHB
  input [1:0] HTRANS,
  input [31:0] HADDR,
  input HWRITE,
  input HREADY,
  input [1:0] HRESP,
  input EXREQ,
  output reg EXRESP
);

reg [31:0] haddr_latch;
reg [31:0] manage_access;
reg [31:0] manage_addr;
reg manage_valid;

always @ (posedge HCLK or negedge HRESETN) begin
  if (!HRESETN) begin
    manage_valid <= 1'b0;
    manage_access <= 1'b0;
    EXRESP <= 1'b0;
  end
  else begin
    haddr_latch <= HADDR;

    // EXREQ and Read Access
    if ((HTRANS == 2'b01 | HTRANS == 2'b10) & !HWRITE & HREADY & EXREQ)
      manage_access <= 1'b1;
    else
      manage_access <= 1'b0;

    if (manage_access & HRESP == 2'b00) begin
      manage_addr <= haddr_latch;
      manage_valid <= 1'b1;
    end

    // EXREQ and Write Access
    if ((HTRANS == 2'b01 | HTRANS == 2'b10) & HWRITE & HREADY & !EXREQ) begin
      manage_valid <= 1'b0;
      EXRESP <= 1'b0;
    end
    else if ((HTRANS == 2'b01 | HTRANS == 2'b10) & HWRITE & HREADY & EXREQ) begin
      if (manage_valid & HADDR == manage_addr) begin
        EXRESP <= 1'b0;
        manage_valid <= 1'b0;
      end
      else begin
        EXRESP <= 1'b1;
        manage_valid <= 1'b0;
      end
    end
    else if (HREADY)
      EXRESP <= 1'b0;
  end
end

endmodule
