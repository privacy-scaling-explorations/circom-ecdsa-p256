pragma circom 2.1.5;

include "../../circuits_p256/ecdsa.circom";

component main {public [r, s, msghash, pubkey]} = ECDSAVerifyNoPubkeyCheck(64, 4);
