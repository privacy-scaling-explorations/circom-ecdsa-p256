pragma circom 2.1.5;

include "../../circuits/secp256k1.circom";

component main {public [in]} = Secp256k1Double(64, 4);
