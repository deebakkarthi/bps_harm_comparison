#!/usr/bin/env python3
import csv
import sys
import os
import argparse


def usage():
    print(
        f"Usage: {prog_name} FILE1 FILE2 [-c|-i]\n",
        "\tCompute the set difference between two csv files\n",
        "\tBy default FILE1 - FILE2 is returned, meaning elements present in FILE1 but not in FILE2\n",
        "\t-c Common. Return the set intersection instead of difference\n",
        "\t-i Invert. Return FILE2 - FILE1",
    )
    return


def print_(
    file1_dict: dict[str, set[str]],
    file2_dict: dict[str, set[str]],
    print_count: bool = False,
    intersection: bool = False,
    as_sva: bool = False,
    category: bool = False,
    file1_status_dict: dict[tuple[str, str], str] = {},
):
    if intersection:
        f = lambda key: file1_dict[key].intersection(
            file2_dict.get(key, set())
        )
    else:
        f = lambda key: file1_dict[key].difference(file2_dict.get(key, set()))

    if print_count:
        for key in file1_dict:
            print(
                key,
                len(f(key)),
            )
    elif as_sva:
        for key in file1_dict:
            for rhs in f(key):
                if category:
                    print(f"{file1_status_dict.get((key, rhs), "")}, ", end="")
                print(
                    f"assert property (@(posedge clk_i) disable iff (!rst_ni) {key} |-> ##1 {rhs});"
                )
    else:
        for key in file1_dict:
            for rhs in f(key):
                if category:
                    print(f"{file1_status_dict.get((key, rhs), "")}, ", end="")
                print(f"{key},{rhs}")
    return


def main():
    parser = argparse.ArgumentParser(
        prog=os.path.basename(sys.argv[0]),
        description="Calculate set difference between FILE1 and FILE2",
    )
    _ = parser.add_argument("FILE1", type=str)
    _ = parser.add_argument("FILE2", type=str)

    group = parser.add_mutually_exclusive_group()
    _ = group.add_argument(
        "-c",
        "--common",
        help="Return the common (set intersection) instead of difference",
        action="store_true",
    )
    _ = group.add_argument(
        "-i", "--invert", help="Return FILE2 - FILE1", action="store_true"
    )
    group2 = parser.add_mutually_exclusive_group()
    _ = group2.add_argument(
        "--count",
        help="Print the count instead of elements",
        action="store_true",
    )
    _ = group2.add_argument(
        "--sva", help="Print as SVA instead of elements", action="store_true"
    )
    _ = parser.add_argument(
        "--category",
        help="Print the category when printing SVA",
        action="store_true",
    )

    args = parser.parse_args()

    file1_path: str = args.FILE1  # pyright: ignore[reportAny]
    file2_path: str = args.FILE2  # pyright: ignore[reportAny]
    common: bool = args.common  # pyright: ignore[reportAny]
    invert: bool = args.invert  # pyright: ignore[reportAny]
    count: bool = args.count  # pyright: ignore[reportAny]
    as_sva: bool = args.sva  # pyright: ignore[reportAny]
    category: bool = args.category  # pyright: ignore[reportAny]

    file1_status_dict: dict[tuple[str, str], str] = {}
    file2_status_dict: dict[tuple[str, str], str] = {}

    file1_dict: dict[str, set[str]] = {}
    with open(file1_path, "r") as f:
        reader = csv.reader(f)
        for row in reader:
            antecedent = row[1]
            consequent = row[2]
            if antecedent not in file1_dict:
                file1_dict[antecedent] = set()
            file1_dict[antecedent].add(consequent)
            file1_status_dict[(antecedent, consequent)] = row[0]

    file2_dict: dict[str, set[str]] = {}
    with open(file2_path, "r") as f:
        reader = csv.reader(f)
        for row in reader:
            antecedent = row[1]
            consequent = row[2]
            if antecedent not in file2_dict:
                file2_dict[antecedent] = set()
            file2_dict[antecedent].add(consequent)
            file2_status_dict[(antecedent, consequent)] = row[0]

    if invert:
        print_(
            file2_dict,
            file1_dict,
            intersection=common,
            print_count=count,
            as_sva=as_sva,
            category=category,
            file1_status_dict=file2_status_dict,
        )
    else:
        print_(
            file1_dict,
            file2_dict,
            intersection=common,
            print_count=count,
            as_sva=as_sva,
            category=category,
            file1_status_dict=file1_status_dict,
        )
    return


prog_name = os.path.basename(sys.argv[0])
if __name__ == "__main__":
    main()
