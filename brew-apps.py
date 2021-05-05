#!/usr/bin/env python

"""Script to find all installed Mac apps that are available via Homebrew."""

import argparse
import json
import sys
import subprocess

# 1. Generate list of installed apps:
#    $ find /Applications -name '*.app' -a -type d -print | sed 's/\/Contents\/.*//' | sort | uniq >apps.txt
#
# 2. Generate JSON for all apps available as casks in Homebrew:
#    $ brew casks | grep -v d12frosted | grep -v zulu | grep -v git-toolbelt | grep -v '^Library' | xargs brew info --cask --json=v2 >allcasks.json


def get_installed_apps():
    print("Getting installed apps...")
    # output = subprocess.check_output("find /Applications -name '*.app' -a -type d -print", shell=True, text=True)
    # raw_apps = output.split("\n")
    # apps = []
    # for line in raw_apps:
    #     if "/Contents/" in line:
    #         continue
    #     apps.append(line)
    # apps.sort()
    with open("apps.txt", "r") as f:
        apps = f.readlines()
    apps = [line.strip('\n') for line in apps]
    return apps


def get_brew_casks(casks_file=None):
    print("Getting Homebrew casks...")
    if casks_file:
        with open(casks_file, "r") as f:
            casks = f.readlines()
        casks = [line.strip('\n') for line in casks]
    else:
        output = subprocess.check_output("brew casks", shell=True, text=True)
        casks = output.split("\n")
    return casks


def get_brew_data(cask):
    print(f"Getting Homebrew data for cask {cask}...")
    try:
        output = subprocess.check_output(f"brew info --cask --json=v2 {cask}", shell=True, text=True)
        data = json.loads(output)
    except subprocess.CalledProcessError:
        return None
    return data


def setup_args(argv):
    parser = argparse.ArgumentParser()

    # Options.
    parser.add_argument(
        "-c", "--casks-file",
        type=str,
        dest="casks_file",
        metavar="FILE",
        help="Casks input file.",
    )
    parser.add_argument(
        "-b", "--brew-data-file",
        type=str,
        dest="brew_data_file",
        metavar="FILE",
        help="Brew data input file.",
    )
    parser.add_argument(
        "-s", "--save-brew-data",
        action="store_true",
        default=False,
        dest="save_brew_data",
        help="Save the fetched Homebrew data.",
    )
    args = parser.parse_args()
    return args


def main(argv=None):
    """Main."""
    argv = (argv or sys.argv)[1:]
    args = setup_args(argv)

    apps = get_installed_apps()

    casks = get_brew_casks(args.casks_file)

    if args.brew_data_file:
        with open(args.brew_data_file, "r") as f:
            cask_data = json.load(f)
    else:
        cask_data = {}
        for cask in casks:
            brew_data = get_brew_data(cask)
            if brew_data is None:
                continue
            if len(brew_data["casks"]) > 1:
                sys.exit(f"Multiple casks for cask {cask}!")
            cask_data[cask] = brew_data["casks"][0]["artifacts"]
    import pprint; pprint.pprint(cask_data)

    if args.save_brew_data:
        with open("caskdata.json", "w") as f:
            json.dump(f, cask_data)


if __name__ == "__main__":
    main()
