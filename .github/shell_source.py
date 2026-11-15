#!/usr/bin/env python3
"""SideStore shell: prints the SideStore source (apps_shell.json) for the app built by this workflow.

The built-in SideStore uses it as its own source, so every new build of the shell shows up
in My Apps > Updates like any other app.
"""
import datetime
import json
import os
import sys

ipa_path = sys.argv[1]
repo = os.environ.get("GITHUB_REPOSITORY", "eliaskinzigeri-blip/LiveContainer")
version = os.environ.get("SHELL_VERSION", "0.0.0")
commit = os.environ.get("GITHUB_SHA", "")[:7]
now = datetime.datetime.now(datetime.timezone.utc)
download_url = f"https://github.com/{repo}/releases/download/shell/SideStore-Shell.ipa"
icon_url = "https://raw.githubusercontent.com/LiveContainer/LiveContainer/main/screenshots/AppIcon1024.png"
description = "SideStore with the LiveContainer engine built in: once the 3 sideloading slots are taken, new apps run inside the app."
size = os.path.getsize(ipa_path)

source = {
    "name": "SideStore shell",
    "identifier": "io.github.eliaskinzigeri-blip.sidestore-shell",
    "website": f"https://github.com/{repo}",
    "subtitle": "SideStore + LiveContainer",
    "description": description,
    "tintColor": "#0784FC",
    "iconURL": icon_url,
    "apps": [
        {
            "beta": False,
            "name": "SideStore shell",
            "bundleIdentifier": "com.kdt.livecontainer",
            "developerName": "SideStore & LiveContainer teams",
            "subtitle": "SideStore + LiveContainer",
            "version": version,
            "versionDate": now.strftime("%Y-%m-%d"),
            "versionDescription": f"Build {commit}.",
            "downloadURL": download_url,
            "localizedDescription": description,
            "iconURL": icon_url,
            "tintColor": "#0784FC",
            "category": "utilities",
            "size": size,
            "screenshotURLs": [],
            "versions": [
                {
                    "version": version,
                    "date": now.strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "localizedDescription": f"Build {commit}.",
                    "downloadURL": download_url,
                    "size": size,
                }
            ],
        }
    ],
    "news": [],
}

print(json.dumps(source, indent=2))
