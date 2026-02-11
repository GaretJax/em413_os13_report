#!/usr/bin/env python3

import os
import re


def print_includes(directory, only, exclude, use_include=True):
    if os.path.exists(directory):
        for f in sorted(os.listdir(directory)):
            f, ext = f.rsplit(".", 1)
            if only and not re.fullmatch(only, f):
                continue
            if exclude and re.fullmatch(exclude, f):
                continue
            if ext == "tex":
                print(
                    r"\{}{{{}}}".format(
                        "include" if use_include else "input",
                        os.path.join(directory, f),
                    )
                )


# Click version removed for compatibility with overleaf
#@click.command()
#@click.option("--use-include/--use-input", "use_include", default=True)
#@click.option("-e", "--exclude", "exclude")
#@click.option("-o", "--only", "only")
#@click.argument(
#    "dirs",
#    metavar="DIR [DIR...]",
#    type=click.Path(file_okay=False),
#    nargs=-1,
#)
def main(dirs, use_include, exclude, only):
    for d in dirs:
        print_includes(d, only, exclude, use_include=use_include)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("-e", "--exclude")
    parser.add_argument("-o", "--only")
    parser.add_argument("--use-include", action="store_true", dest="use_include", default=True)
    parser.add_argument("--use-input", action="store_false", dest="use_include")
    parser.add_argument("dirs", nargs="+", metavar="DIR")

    args = parser.parse_args()

    main(**vars(args))
