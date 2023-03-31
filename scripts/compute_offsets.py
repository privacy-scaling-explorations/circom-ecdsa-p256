import compute_p256_math
import math
import sys

return_str = ""


def offsets(num_registers, n, k):
    return_str = "PrimeReduce" + str(num_registers) + "Registers: \n"
    matrix = []
    for idx in range(num_registers):
        coeff = 2**(64*idx) % compute_p256_math.P
        long_coeff = compute_p256_math.get_long(n, k, coeff)
        matrix.append(long_coeff)
        return_str += "in[" + str(idx) + "], coeffs = " + \
            str(long_coeff) + '\n'
    return_str += "\n"
    return_str += "matrix of coefficients = " + str(matrix) + "\n" + "\n"

    return return_str


return_str += offsets(7, 64, 4) + offsets(10, 32, 8)

orig_stdout = sys.stdout
f = open('../script_outputs/offsets_out.circom', 'w')
sys.stdout = f

print(return_str)
