pragma circom 2.1.5;

include "../../circuits_p256/p256.circom";

component main {public [a, b]} = P256AddUnequal(64, 4);
