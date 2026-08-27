module cla64_flat(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [63:0] p, g;
  wire [64:1] c;

  genvar i, j;
  generate
    // Step 1: generate/propagate signals
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end

    // Step 2: 64 direct carry equations
    for (i = 1; i <= 64; i = i + 1) begin : gen_c
      wire [i:0] terms;
      assign terms[0] = (&p[i-1:0]) & cin;
      for (j = 1; j <= i; j = j + 1) begin : gen_t
        if (j == i)
          assign terms[j] = g[i-1];
        else
          assign terms[j] = (&p[i-1:j]) & g[j-1];
      end
      assign #(2) c[i] = |terms;
    end
  endgenerate

  assign cout = c[64];

  // Step 3: sum bits
  assign #(2) sum = p ^ {c[63:1], cin};

endmodule