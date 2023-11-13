pragma circom 2.1.5;

include "../../circuits/p256_utils.circom";
include "../../circuits/bigint.circom";
include "../../circuits/bigint_4x64_mult.circom";

component main {public [in]} = P256PrimeReduce10Registers();
