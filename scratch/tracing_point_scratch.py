x = 5066263022277343669578718895168534326250603453777594175500187360389116729240
y = 32670510020758816978083085130507043184471273380659243275938904335757337482424
A = 115792089210356248762697446949407573530086143415290314195533631308867097853948
B = 41058363725152142129326129780047268409114441015993725554835256314039467401291
P = 115792089210356248762697446949407573530086143415290314195533631308867097853951

print(((x**3 + A * x + B - y**2) % P) == 0)

parameters = {
    "P": 115792089210356248762697446949407573530086143415290314195533631308867097853951,
    "N": 115792089210356248762697446949407573529996955224135760342422259061068512044369,
    "A": 115792089210356248762697446949407573530086143415290314195533631308867097853948,
    "B": 41058363725152142129326129780047268409114441015993725554835256314039467401291,
    "Gx": 48439561293906451759052585252797914202762949526041747995844080717082404635286,
    "Gy": 36134250956749795798585127919587881956611106672985015071877198253568414405109,
}
# supposed to be on the curve, let's trace witness computation thru the circuits
# P256PointOnCurve

# // DONE
# // Implements:
# // x^3 + Ax + B - y^2 == 0 mod p
# // where A, B, p are params of P256 curve (p is field size)
# template P256PointOnCurve() {
#     signal input x[4];
#     signal input y[4];

#     // first, we compute representations of x^3 and y^2.
#     // these representations have overflowed, nonnegative registers
#     signal x3[10]; // 197 bits
#     component x3Comp = A3NoCarry();
#     for (var i = 0; i < 4; i++) x3Comp.a[i] <== x[i];
#     for (var i = 0; i < 10; i++) x3[i] <== x3Comp.a3[i];

#     signal y2[7]; // 130 bits
#     component y2Comp = A2NoCarry();
#     for (var i = 0; i < 4; i++) y2Comp.a[i] <== y[i];
#     for (var i = 0; i < 7; i++) y2[i] <== y2Comp.a2[i];

#     // next, we compute representations of Ax and B.
#     signal A[4];
#     var tmpA[100] = get_A(64, 4);
#     for (var i = 0; i < 4; i++) A[i] <== tmpA[i];

#     signal B[4];
#     var tmpB[100] = get_B(64, 4);
#     for (var i = 0; i < 4; i++) B[i] <== tmpB[i];

#     signal Ax[7];
#     component AxComp = BigMultNoCarry(64, 64, 64, 4, 4);
#     for (var i = 0; i < 4; i++) AxComp.a[i] <== x[i];
#     for (var i = 0; i < 4; i++) AxComp.b[i] <== A[i];
#     for (var i = 0; i < 7; i++) Ax[i] <== AxComp.out[i];

#     component zeroCheck = CheckCubicModPIsZero(197); // 197 bits per register
#     for (var i = 0; i < 10; i++) {
#         if (i < 4) zeroCheck.in[i] <== x3[i] - y2[i] + Ax[i] + B[i];
#         else if (i < 7) zeroCheck.in[i] <== x3[i] - y2[i] + Ax[i];
#         else zeroCheck.in[i] <== x3[i];
#     }
# }
