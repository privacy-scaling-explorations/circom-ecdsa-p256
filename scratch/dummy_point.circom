pragma circom 2.0.2;

include "p256_func.circom";
include "bigint.circom";
include "bigint_func.circom";

template dummy_point(n, k) {
    signal input G[2][k];
    signal dummy;
    signal output out[2][100];

    var g1[k];
    var g2[k];
    dummy <== G[0][0] * G[0][0] + G[0][0];

    for (var i=0; i<k; i++) {
        g1[i] = G[0][i];
        g2[i] = G[1][i];
    }

    var tmp[2][100];
    //  = p256_double_func(n, k, g1, g2);
    
    // double generator point 255 times
    for (var i=0; i<255; i++) {
        tmp = p256_double_func(n, k, g1, g2);
        for (var j=0; j<k; j++) {
            g1[j] = tmp[0][j];
            g2[j] = tmp[1][j];
        }
    }

    for (var i=0; i<k; i++) {
        out[0][i] <-- g1[i];
        out[1][i] <-- g2[i];
    }

}
