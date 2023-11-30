pragma circom 2.1.5;

include "../../circuits/p256.circom";

component main {public [scalar, point]} = P256ScalarMult(43, 6);
