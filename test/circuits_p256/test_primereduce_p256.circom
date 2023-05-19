pragma circom 2.0.2;

include "../../circuits_p256/p256_utils.circom";

component main {public [out]} = PrimeReduce10Registers(64, 4);
