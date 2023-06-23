pragma circom 2.1.5;

include "../../circuits/secp256k1.circom";

component main {public [x, y]} = Secp256k1PointOnCurve();
