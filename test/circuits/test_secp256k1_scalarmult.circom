pragma circom 2.1.5;

include "../../circuits/secp256k1.circom";

component main {public [scalar, point]} = Secp256k1ScalarMult(64, 4);
