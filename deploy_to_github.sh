#!/usr/bin/env bash
set -e

echo "========================================================"
echo " Hardware-and-FPGA-Portfolio GitHub Update Script"
echo " Author: Abdullah SONMEZ (github.com/abdullahssonmez)"
echo "========================================================"

git init
git branch -M main

git add .
git commit -m "docs: update portfolio READMEs and add latest CV & Hardware Portfolio PDF"

git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/abdullahssonmez/Hardware-and-FPGA-Portfolio.git

echo "Pushing updated repository to https://github.com/abdullahssonmez/Hardware-and-FPGA-Portfolio.git ..."
git push -u origin main --force

echo "Update complete!"
