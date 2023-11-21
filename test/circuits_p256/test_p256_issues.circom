pragma circom 2.1.5;

//include "../../circuits/p256_utils.circom";
//include "../../circuits/bigint.circom";
//include "../../circuits/bigint_4x64_mult.circom";
include "../../circuits/circom-pairing/circuits/bigint.circom";

component main = PrimeReduce(64, 4, 6, [18446744073709551615,4294967295,0,18446744069414584321], 64);
