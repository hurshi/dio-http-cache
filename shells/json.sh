#!/usr/bin/env bash
flutter packages pub run build_runner build --define "json_serializable=any_map=true" --delete-conflicting-outputs
