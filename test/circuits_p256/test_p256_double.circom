pragma circom 2.1.5;

include "../../circuits/p256.circom";

component main {public [in]} = P256Double(64, 4);
