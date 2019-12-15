#!/bin/bash
source ./backup.config

borg init --encryption=repokey $REPO_LOCAL
