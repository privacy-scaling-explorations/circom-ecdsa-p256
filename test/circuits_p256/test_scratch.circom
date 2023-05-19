pragma circom 2.0.2;

include "../../circuits_p256/scratch.circom";

component main {public [a, b]} = longDivision(32, 8);
