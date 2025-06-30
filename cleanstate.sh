#!/bin/bash

git branch -D state
git push origin --delete state

git switch --orphan state
git commit --allow-empty -m "Initialize state branch"
git push origin state

git checkout main