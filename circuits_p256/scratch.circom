pragma circom 2.1.5;

include "bigint_func.circom";
include "p256_func.circom";

template longDivision(n, k, m) {
    signal input a;
    signal input b;

    signal output q[m+1];

    // long_div(n, k, m, a, b) spec:
    // n bits per register
    // a has k + m registers
    // b has k registers
    // out[0] has length m + 1 -- quotient
    // out[1] has length k -- remainder
    // implements algorithm of https://people.eecs.berkeley.edu/~fateman/282/F%20Wright%20notes/week4.pdf
    // b[k-1] must be nonzero!
    var qtemp[2][100] = long_div(n, k, m, a, b)

    for (var i = 0; i < m+1; i++) {
        q[i] <-- qVarTemp[0][i];
        log(q[i]);
    }

}
