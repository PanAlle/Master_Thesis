#!/bin/sh

TEX_FILE_NAME=main
REMOTE_HOST=address of remote hosts
REMOTE_USER=remote user
REMOTE_DIR=path to remote directory

# Save the current commit id and cut it
CURRENT=`git rev-parse HEAD | cut -c -10`

# Compile the LaTex stuff
pdflatex -interaction=batchmode $TEX_FILE_NAME.tex > /dev/null
bibtex -terse $TEX_FILE_NAME
pdflatex -interaction=batchmode $TEX_FILE_NAME.tex > /dev/null
pdflatex -interaction=batchmode $TEX_FILE_NAME.tex

# Create versions dir if it does not exist
ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $REMOTE_DIR/versions"

# Create a folder for the new build
NOW=$(date +"%d%m%Y-%H%M")
OUT_DIR=$REMOTE_DIR/versions/$NOW-$CURRENT
ssh $REMOTE_USER@$REMOTE_HOST "mkdir $OUT_DIR"

# Move the compiled pdf to the output directory (versions dir)
scp $TEX_FILE_NAME.pdf $REMOTE_USER@$REMOTE_HOST:$OUT_DIR/gradu_seppa-lassila_$NOW-$CURRENT.pdf

# Get diff and copy to remote server (versions dir)
git diff HEAD^ HEAD | pygmentize -l diff -f html -O full | ssh $REMOTE_USER@$REMOTE_HOST " cat > \"$OUT_DIR\"/diff-\"$CURRENT\".html "

# Move the compiled pdf to the output directory (lastest version, root dir)
scp $TEX_FILE_NAME.pdf $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/Ales_pan.pdf

# Get diff and copy to remote server (latest version, root dir)
git diff HEAD^ HEAD | pygmentize -l diff -f html -O full | ssh $REMOTE_USER@$REMOTE_HOST " cat > \"$REMOTE_DIR\"/diff-latest.html "
