#!/bin/bash

git branch -D state
git push origin --delete state

git switch --orphan state
git checkout main