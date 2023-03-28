pragma circom 2.0.2;

include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../circuits_p256/dummy_point.circom";

component main = dummy_point(86, 3);
// component main = dummy_point(64, 4);
