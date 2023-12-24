import sys
import re
import numpy as np


def intersection_point_2d(set1, set2):
    # Extract the points and vectors from the sets
    point1 = np.array([set1["px"], set1["py"]])
    vector1 = np.array([set1["vx"], set1["vy"]])
    point2 = np.array([set2["px"], set2["py"]])
    vector2 = np.array([set2["vx"], set2["vy"]])

    # Create the coefficients matrix
    A = np.array([vector1, -vector2]).T

    # Create the constants vector
    b = point2 - point1

    try:
        # Solve the system of equations
        t, s = np.linalg.solve(A, b)

        if t < 0 or s < 0:
            return None

        # Calculate the intersection point
        intersection = point1 + t * vector1

        return intersection.tolist()
    except np.linalg.LinAlgError:
        # The lines do not intersect
        return None


def test_stones_crossing_2d(a, b, min, max):
    p = intersection_point_2d(a, b)
    if p is None:
        return False
    return min <= p[0] <= max and min <= p[1] <= max


def parse_line(line):
    parts = line.split(" @ ")
    p = list(map(int, re.split(",\\s+", parts[0])))
    v = list(map(int, re.split(",\\s+", parts[1])))

    return {"px": p[0], "py": p[1], "pz": p[2], "vx": v[0], "vy": v[1], "vz": v[2]}


def unpack_variables(line_dict):
    cpx, cpy, cpz = line_dict["px"], line_dict["py"], line_dict["pz"]
    cvx, cvy, cvz = line_dict["vx"], line_dict["vy"], line_dict["vz"]
    return cpx, cpy, cpz, cvx, cvy, cvz


def find_intersection(lines):
    import z3

    answer = 0

    solver = z3.Solver()
    x, y, z, vx, vy, vz = [z3.Int(var) for var in ["x", "y", "z", "vx", "vy", "vz"]]

    for itx in range(4):
        line_dict = lines[itx]
        cpx, cpy, cpz, cvx, cvy, cvz = unpack_variables(line_dict)

        t = z3.Int(f"t{itx}")
        solver.add(t >= 0)
        solver.add(x + vx * t == cpx + cvx * t)
        solver.add(y + vy * t == cpy + cvy * t)
        solver.add(z + vz * t == cpz + cvz * t)

    if solver.check() == z3.sat:
        model = solver.model()
        (x, y, z) = (model.eval(x), model.eval(y), model.eval(z))
        answer = x.as_long() + y.as_long() + z.as_long()
    print(f"Part 2: {answer}")


def main():
    if len(sys.argv) < 2:
        print("Please provide a filename as a command line argument.")
        return

    filename = sys.argv[1]

    if filename == "example.txt":
        min_value = 7
        max_value = 27
    else:
        min_value = 200000000000000
        max_value = 400000000000000

    with open(filename, "r") as f:
        lines = [parse_line(line) for line in f]

    count = 0
    for i in range(len(lines)):
        for j in range(i + 1, len(lines)):
            if test_stones_crossing_2d(lines[i], lines[j], min_value, max_value):
                count += 1

    print(f"Part 1: {count}")

    find_intersection(lines)


if __name__ == "__main__":
    main()
