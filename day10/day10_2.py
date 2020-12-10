import sys


def traverse(current_idx=0, table={}):
    if current_idx == len(adapters) - 1:
        table[current_idx] = 1
        return 1

    current = adapters[current_idx]
    option_idxs = range(current_idx + 1, current_idx + 4)
    to_search = [i for i in option_idxs if i < len(
        adapters) and adapters[i] - 3 <= current]

    sum = 0
    for search_idx in to_search:
        if search_idx in table:
            sum += table[search_idx]
            continue
        sum += traverse(search_idx, table)

    table[current_idx] = sum
    return table[current_idx]


if __name__ == "__main__":
    adapters = sorted(
        list(map(lambda s: int(s.rstrip()), sys.stdin.readlines())))
    adapters.insert(0, 0)
    adapters.append(adapters[-1] + 3)

    print(traverse())
