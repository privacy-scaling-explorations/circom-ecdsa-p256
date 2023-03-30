// TODO FILE

pragma circom 2.0.2;

include "bigint_func.circom";

// P = 2^256 - 2^224 + 2^192 + 2^96 - 1

// input: 10 registers, 64 bits each. registers can be overful
// returns: reduced number with 4 registers, preserving residue mod P
// TODO: changing the curve...
//      offset is too big to use immediately (on the order of 2^224)
//      need overflow to be at most 53, since there are 200-bit overflow inputs (see p256.circom circuit AddUnequalCubicConstraint)
template Secp256k1PrimeReduce10Registers()
    signal input in[10];

    signal output out[4];
    // var offset = (1<<32) + 977; // 33 bits 
    // var offset2 = ((1<<33) * 977) + (977 ** 2); // 43 bits
    // offset = 4 registers over = * 2^256 (mod P) = (* 2^224 - 2^192 - 2^96 + 1  (mod P)
    var offset = (1<<96) * (1<<128- 1) / (1<<4 - 1) - (1<<192); // ~220 bits......

    
    out[3] <== (offset * in[7]) + in[3]; // 4 registers over = * 2^256 = * offset (mod P)
    out[2] <== (offset * in[6]) + in[2] + in[9]; // offset2 techincally includes 1<<64 => in[9] carries over from out[1]
    out[1] <== (offset2 * in[9]) + (offset * in[5]) + in[1] + in[8];
    out[0] <== (offset2 * in[8]) + (offset * in[4]) + in[0];
}

// input: 7 registers, 64 bits each. registers can be overful
// returns: reduced number with 4 registers, preserving residue mod P
// TODO: changing the curve...
//      offset is too big to use immediately (on the order of 2^224)
//      need overflow to be at most 53, since there are 200-bit overflow inputs (see p256.circom circuit AddUnequalCubicConstraint)
template Secp256k1PrimeReduce7Registers() {
    signal input in[7];

    signal output out[4];
    var offset = (1<<32) + 977; // 33 bits
    
    out[3] <== in[3];
    out[2] <== (offset * in[6]) + in[2];
    out[1] <== (offset * in[5]) + in[1];
    out[0] <== (offset * in[4]) + in[0];
}

// DONE
// check that in is in range [0, P-1]
// want to look at P base 2^64 - as long as number is less than that, good (check ranges from largest to smallest digit)
// P = 18446744073709551615 * 2^0 + 4294967295 * 2^64 + 0 * 2^128 + 18446744069414584321 * 2^192
template CheckInRangeP256 () {
    signal input in[4];

    component firstPlaceLessThan = LessThan(64);
    firstPlaceLessThan.in[0] <== in[3];
    firstPlaceLessThan.in[1] <== 18446744069414584321;

    component firstPlaceEqual = IsEqual()
    firstPlaceEqual.in[0] <== in[3];
    firstPlaceEqual.in[1] <== 18446744069414584321;

    component secondPlaceLessThan = LessThan(64);
    secondPlaceLessThan.in[0] <== in[2];
    secondPlaceLessThan.in[1] <== 0;

    component secondPlaceEqual = IsEqual()
    secondPlaceEqual.in[0] <== in[2];
    secondPlaceEqual.in[1] <== 0;

    component thirdPlaceLessThan = LessThan(64);
    thirdPlaceLessThan.in[0] <== in[1];
    thirdPlaceLessThan.in[1] <== 4294967295;

    component thirdPlaceEqual = IsEqual()
    thirdPlaceEqual.in[0] <== in[1];
    thirdPlaceEqual.in[1] <== 4294967295;

    component fourthPlaceLessThan = LessThan(64);
    fourthPlaceLessThan.in[0] <== in[0];
    fourthPlaceLessThan.in[1] <== 18446744073709551615;

    component fourthPlaceEqual = IsEqual()
    fourthPlaceEqual.in[0] <== in[0];
    fourthPlaceEqual.in[1] <== 18446744073709551615;

    signal l1 <== 1 - firstPlaceLessThan.out;
    signal e1 <== 1 - firstPlaceEqual.out;
    signal l2 <== 1 - secondPlaceLessThan.out;
    signal e2 <== 1 - secondPlaceEqual.out;
    signal l3 <== 1 - thirdPlaceLessThan.out;
    signal e3 <== 1 - thirdPlaceEqual.out;
    signal l4 <== 1 - fourthPlaceLessThan.out;
    signal e4 <== 1 - fourthPlaceEqual.out;

    // d1d2d3d4 < P <=> (d1 less) OR 
    //                  (d1 equal and d2 less) OR
    //                  (d1 equal and d2 equal and d3 less) OR 
    //                  (d1 equal and d2 equal and d3 equal and d4 less)
    (l1 * (e1 + l2) * (e1 + e2 + l3) * (e1 + e2 + e3 + l4)) === 0;

}

// DONE
// 64 bit registers with m-bit overflow
// registers (and overall number) are potentially negative
template CheckCubicModPIsZero(m) {
    assert(m < 206); // since we deal with up to m+46 bit, potentially negative registers

    signal input in[10];

    // the p256 field size, hardcoded
    signal p[4];
    p[0] <== 18446744073709551615;
    p[1] <== 4294967295;
    p[2] <== 0;
    p[3] <== 18446744069414584321;

    // now, we compute a positive number congruent to `in` expressible in 4 overflowed registers.
    // for this representation, individual registers are allowed to be negative, but the final number
    // will be nonnegative overall.
    // first, we apply the secp 10-register reduction technique to reduce to 4 registers. this may result
    // in a negative number overall, but preserves congruence mod p.
    // our intermediate result is z = secpReduce(in)
    // second, we add a big multiple of p to z, to ensure that our final result is positive. 
    // since the registers of z are m + 43 bits, its max abs value is 2^(m+43 + 192) + 2^(m+43 + 128) + ...
    // so we add p * 2^(m-20), which is a bit under 2^(m+236) and larger than |z| < 2^(m+43+192) + eps
    signal reduced[4];
    component secpReducer = Secp256k1PrimeReduce10Registers();
    for (var i = 0; i < 10; i++) {
        secpReducer.in[i] <== in[i];
    }
    signal multipleOfP[4];
    for (var i = 0; i < 4; i++) {
        multipleOfP[i] <== p[i] * (1 << (m-20)); // m - 20 + 64 = m+44 bits
    }
    for (var i = 0; i < 4; i++) {
        reduced[i] <== secpReducer.out[i] + multipleOfP[i]; // max(m+43, m+44) + 1 = m+45 bits
    }

    // now we compute the quotient q, which serves as a witness. we can do simple bounding to show
    // that the the expected quotient is always expressible in 3 registers (i.e. < 2^192)
    // so long as m < 211
    signal q[3];

    var temp[100] = getProperRepresentation(m + 45, 64, 4, reduced);
    var proper[8];
    for (var i = 0; i < 8; i++) {
        proper[i] = temp[i];
    }

    var qVarTemp[2][100] = long_div(64, 4, 4, proper, p);
    for (var i = 0; i < 3; i++) {
        q[i] <-- qVarTemp[0][i];
    }

    // we need to constrain that q is in proper (3x64) representation
    component qRangeChecks[3];
    for (var i = 0; i < 3; i++) {
        qRangeChecks[i] = Num2Bits(64);
        qRangeChecks[i].in <== q[i];
    }

    // now we compute a representation qpProd = q * p
    signal qpProd[6];
    component qpProdComp = BigMultNoCarry(64, 64, 64, 3, 4);
    for (var i = 0; i < 3; i++) {
        qpProdComp.a[i] <== q[i];
    }
    for (var i = 0; i < 4; i++) {
        qpProdComp.b[i] <== p[i];
    }
    for (var i = 0; i < 6; i++) {
        qpProd[i] <== qpProdComp.out[i]; // 130 bits
    }

    // finally, check that qpProd == reduced
    component zeroCheck = CheckCarryToZero(64, m + 46, 6);
    for (var i = 0; i < 6; i++) {
        if (i < 4) { // reduced only has 4 registers
            zeroCheck.in[i] <== qpProd[i] - reduced[i]; // (m + 45) + 1 bits
        } else {
            zeroCheck.in[i] <== qpProd[i];
        }
    }
}

// DONE
// 64 bit registers with m-bit overflow
// registers (and overall number) are potentially negative
template CheckQuadraticModPIsZero(m) {
    assert(m < 147); // so that we can assume q has 2 registers

    signal input in[7];

    // the p256 field size, hardcoded
    signal p[4];
    p[0] <== 18446744073709551615;
    p[1] <== 4294967295;
    p[2] <== 0;
    p[3] <== 18446744069414584321;

    // now, we compute a positive number congruent to `in` expressible in 4 overflowed registers.
    // for this representation, individual registers are allowed to be negative, but the final number
    // will be nonnegative overall.
    // first, we apply the secp 7-register reduction technique to reduce to 4 registers. this may result
    // in a negative number overall, but preserves congruence mod p.
    // our intermediate result is z = secpReduce(in)
    // second, we add a big multiple of p to z, to ensure that our final result is positive. 
    // since the registers of z are m + 33 bits, its max abs value is 2^(m+33 + 192) + 2^(m+33 + 128) + ...
    // so we add p * 2^(m-30), which is a bit under 2^(m+226) and larger than |z| < 2^(m+33+192) + eps
    signal reduced[4];
    component secpReducer = Secp256k1PrimeReduce7Registers();
    for (var i = 0; i < 7; i++) {
        secpReducer.in[i] <== in[i];
    }
    signal multipleOfP[4];
    for (var i = 0; i < 4; i++) {
        multipleOfP[i] <== p[i] * (1 << (m-30)); // m - 30 + 64 = m + 34 bits
    }
    for (var i = 0; i < 4; i++) {
        reduced[i] <== secpReducer.out[i] + multipleOfP[i]; // max(m+33, m+34) + 1 = m+35 bits
    }

    // now we compute the quotient q, which serves as a witness. we can do simple bounding to show
    // that the the expected quotient is always expressible in 2 registers (i.e. < 2^192)
    // so long as m < 147
    signal q[2];

    var temp[100] = getProperRepresentation(m + 35, 64, 4, reduced);
    var proper[8];
    for (var i = 0; i < 8; i++) {
        proper[i] = temp[i];
    }

    var qVarTemp[2][100] = long_div(64, 4, 4, proper, p);
    for (var i = 0; i < 2; i++) {
        q[i] <-- qVarTemp[0][i];
    }

    // we need to constrain that q is in proper (2x64) representation
    component qRangeChecks[2];
    for (var i = 0; i < 2; i++) {
        qRangeChecks[i] = Num2Bits(64);
        qRangeChecks[i].in <== q[i];
    }

    // now we compute a representation qpProd = q * p
    signal qpProd[5];
    component qpProdComp = BigMultNoCarry(64, 64, 64, 2, 4);
    for (var i = 0; i < 2; i++) {
        qpProdComp.a[i] <== q[i];
    }
    for (var i = 0; i < 4; i++) {
        qpProdComp.b[i] <== p[i];
    }
    for (var i = 0; i < 5; i++) {
        qpProd[i] <== qpProdComp.out[i]; // 130 bits
    }

    // finally, check that qpProd == reduced
    component zeroCheck = CheckCarryToZero(64, m + 36, 5);
    for (var i = 0; i < 5; i++) {
        if (i < 4) { // reduced only has 4 registers
            zeroCheck.in[i] <== qpProd[i] - reduced[i]; // (m + 35) + 1 bits
        } else {
            zeroCheck.in[i] <== qpProd[i];
        }
    }
}