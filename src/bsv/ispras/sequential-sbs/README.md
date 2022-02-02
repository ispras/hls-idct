# Sequential-SBS
Sequential implementation of IDCT algorithm.

The program includes AXI-like wrapper that operates in a symbol-by-symbol (SBS)
manner. It means, that the wrapper accumulates elements (so called symbols)
of an input matrix, next passes the matrix to IDCT module, receives an output
matrix and sends output matrix' symbols back.
