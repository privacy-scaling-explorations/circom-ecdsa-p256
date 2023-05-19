pragma circom 2.0.2;

include "../../circuits_p256/p256.circom";

component main {public [a, b]} = P256AddUnequal(64, 4);
