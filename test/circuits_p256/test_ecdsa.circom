pragma circom 2.1.5;

include "../../circuits/ecdsa.circom";

component main {public [privkey]} = ECDSAPrivToPub(64, 4);
