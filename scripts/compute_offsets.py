import compute_p256_math
import math
import sys

return_str = ""

return_str += "PrimeReduce7Registers: \n"
for idx in range(4, 7):
    coeff = 2**(64*idx) % compute_p256_math.P
    long_coeff = compute_p256_math.get_long(64, 4, coeff)
    return_str += "in[" + str(idx) + "], coeffs = " + str(long_coeff) + '\n'

return_str += "\n PrimeReduce10Registers: \n"
for idx in range(10):
    coeff = 2**(64*idx) % compute_p256_math.P
    long_coeff = compute_p256_math.get_long(32, 8, coeff)
    return_str += "in[" + str(idx) + "], coeffs = " + str(long_coeff) + '\n'

orig_stdout = sys.stdout
f = open('../script_outputs/offsets_out.circom', 'w')
sys.stdout = f

print(return_str)
