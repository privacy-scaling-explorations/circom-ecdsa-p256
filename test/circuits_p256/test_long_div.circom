pragma circom 2.1.5;

include "../../circuits/long_div.circom";

component main {public [a, b]} = longDivision(32, 8);
