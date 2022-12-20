#!/usr/bin/env python3


def main():
    gas_snapshot = open(".gas-snapshot").readlines()

    tests = set()
    results = dict()
    for line in gas_snapshot:
        # ['ShowtimeEditions:testContractURI()', '(gas:', '42595)']
        tokens = line.split()
        collection = tokens[0].split(":")[0]
        if collection not in results:
            results[collection] = dict()

        test = tokens[0].split(":")[1]
        tests.add(test)

        gas = int(tokens[2].strip().replace(")", ""))

        results[collection][test] = gas

    print("test\tZoraEditions\tShowtimeEditions")

    for test in sorted(tests):
        print(test, end="\t")
        for collection in ["ZoraEditions", "ShowtimeEditions"]:
            if test in results[collection]:
                print(results[collection][test], end="\t")
            else:
                print("-", end="\t")
        print()


if __name__ == "__main__":
    main()
