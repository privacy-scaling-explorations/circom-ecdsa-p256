pragma circom 2.1.5;

include "../../circuits/circom-pairing/circuits/curve.circom";
include "../../circuits/p256_func.circom";

template TestP256PointOnCurve(n,k) {
  signal input x[k];
  signal input y[k];

  var params[4][k] = get_p256_params();

  component poc = PointOnCurve(n, k, params[0], params[1], params[2]);
  poc.in[0] <== x;
  poc.in[1] <== y;
}
component main {public [x, y]} = TestP256PointOnCurve(43, 6);
