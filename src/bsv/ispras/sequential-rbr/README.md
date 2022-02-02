# Sequential-RBR
Sequential implementation of IDCT algorithm.

The program includes AXI-like wrapper that operates in a row-by-row (RBR)
manner. It means, that the wrapper accumulates rows of an input matrix,
next passes the matrix to IDCT module, receives an output matrix and sends
output matrix' rows back.
