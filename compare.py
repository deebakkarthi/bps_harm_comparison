#!/usr/bin/env python3
import csv
import sys
import os
import argparse


def file_to_dict(file_path: str):
    file_dict: dict[tuple[str, str], str] = {}
    with open(file_path, "r") as f:
        reader = csv.reader(f)
        for row in reader:
            file_dict[(row[1], row[2])] = row[0]
    return file_dict


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

    args = parser.parse_args()

    file1_path: str = args.FILE1  # pyright: ignore[reportAny]
    file2_path: str = args.FILE2  # pyright: ignore[reportAny]
    common: bool = args.common  # pyright: ignore[reportAny]
    invert: bool = args.invert  # pyright: ignore[reportAny]

    file1_dict = file_to_dict(file1_path)
    file2_dict = file_to_dict(file2_path)
    file1_set = set(file1_dict.keys())
    file2_set = set(file2_dict.keys())
    if common:
        set_to_print = file1_set.intersection(file2_set)
        assert set_to_print == file2_set.intersection(file1_set)
        set_to_print = sorted(list(set_to_print))
        for rule in set_to_print:
            print(f'"{file1_dict[rule]}", "{rule[0]}", "{rule[1]}"')
    elif invert:
        set_to_print = file2_set.difference(file1_set)
        set_to_print = sorted(list(set_to_print))
        for rule in set_to_print:
            print(f'"{file2_dict[rule]}", "{rule[0]}", "{rule[1]}"')
    else:
        set_to_print = file1_set.difference(file2_set)
        set_to_print = sorted(list(set_to_print))
        for rule in set_to_print:
            print(f'"{file1_dict[rule]}", "{rule[0]}", "{rule[1]}"')
    return


prog_name = os.path.basename(sys.argv[0])
if __name__ == "__main__":
    main()
