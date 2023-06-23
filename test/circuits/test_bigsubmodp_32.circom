pragma circom 2.1.5;

include "../../circuits/bigint.circom";

component main {public [a, b, p]} = BigSubModP(3, 2);
