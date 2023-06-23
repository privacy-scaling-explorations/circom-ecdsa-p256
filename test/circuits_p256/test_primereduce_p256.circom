pragma circom 2.1.5;

include "../../circuits_p256/p256_utils.circom";

component main {public [out]} = PrimeReduce10Registers(64, 4);
