pragma circom 2.1.5;

include "../../circuits/secp256k1.circom";

component main {public [a, b]} = Secp256k1AddUnequal(64, 4);
