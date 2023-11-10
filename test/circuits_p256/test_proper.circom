pragma circom 2.1.5;

include "../../circuits_p256/bigint_func.circom";

template TestProper(m,n,k) {
  signal input in[k];

  var temp[100] = getProperRepresentation(m,n,k,in);
  var out_size = k;
  if (m % n == 0) {
    out_size += m \ n;
  } else {
    out_size += m \ n + 1;
  }
  signal output out[out_size];
  for (var i = 0; i < out_size; i++) {
    out[i] <-- temp[i];
  }
}
