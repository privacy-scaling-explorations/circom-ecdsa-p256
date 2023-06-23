pragma circom 2.1.5;

include "../../circuits_p256/p256.circom";

component main {public [scalar, point]} = P256ScalarMult(64, 4);
