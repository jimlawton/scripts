#!/usr/bin/env python

"""Script to fetch all MP3 files in an RSS feed."""

import argparse
import os
import requests
import sys
import wget

import feedparser


def setup_args(argv):
    parser = argparse.ArgumentParser()

    # Options.
    parser.add_argument(
        "url",
        type=str,
        metavar="URL",
        help="Feed URL.",
    )
    args = parser.parse_args()
    return args


def main(argv=None):
    """Main."""
    argv = (argv or sys.argv)[1:]
    args = setup_args(argv)

    feed = feedparser.parse(args.url)
    print(feed['feed']['title'])

    for entry in reversed(feed.entries):
        title = f"{entry['title']}"
        print(title)
        filename = "".join([c for c in title if c.isalpha() or c.isdigit() or c ==' ']).rstrip()
        print(filename)
        os.makedirs(f"./{feed['feed']['title']}", exist_ok=True)
        filepath = f"./{feed['feed']['title']}/{filename}"
        print(f"{filepath}.mp3")
        if os.path.exists(f"{filepath}.mp3"):
            print(f"Skipping {filepath}.mp3, already exists")
            continue
        response = requests.get(entry["links"][0]["href"])
        with open(f"{filepath}.mp3", 'wb') as f:
            f.write(response.content)
        with open(f"{filepath}.txt", 'w') as f:
            f.write(entry["author"])
            f.write("\n")
            f.write(entry["title"])
            f.write("\n")
            f.write(entry["subtitle"])
            f.write("\n")
            f.write(entry["content"][0]["value"])
            f.write("\n")
            f.write(entry["links"][0]["href"])
            f.write("\n")


if __name__ == "__main__":
    main()
