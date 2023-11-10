pragma circom 2.1.5;

include "../../circuits_p256/p256_utils.circom";
include "../../circuits_p256/bigint.circom";
include "../../circuits_p256/bigint_4x64_mult.circom";

component main {public [in]} = P256PrimeReduce7Registers();
