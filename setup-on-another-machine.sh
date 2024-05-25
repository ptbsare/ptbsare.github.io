#!/bin/sh
set -e
SUC="1"
CURRENT=`pwd`
BASENAME=`basename "$CURRENT"`
if [ "$BASENAME"x = "blog_hexo_source"x ];then
        cd ..
#	echo "cd .."
fi
if [ ! -d "blog_hexo_source/.git" ]; then
        echo -e  "Start Clone Source Git Repo... \n"
        git clone https://github.com/ptbsare/blog_hexo_source.git &&echo -e  "Source Git Repo SUCCESS! \n"|| ( echo -e  "Source Git Repo Failed! \n"&&export SUC=0&&exit)
    else
        cd blog_hexo_source&&echo -e  "Pull Source Repo..."&& git  pull&&cd ..&&echo -e  "Source Git Repo SUCCESS! \n"|| ( cd ..&& echo -e  "Source Git Repo Failed! \n"&&export SUC=0&&exit)


fi
CURRENT=`pwd`
BASENAME=`basename "$CURRENT"`
if [ "$BASENAME"x = "blog_hexo_source"x ];then
        cd ..
fi


if [ ! -d "blog_hexo_source/.deploy/.git" ]; then
        echo -e  "Start Clone Source Git Repo... \n"
        git clone https://github.com/ptbsare/ptbsare.github.io.git blog_hexo_source/.deploy &&echo -e  "Deploy Git Repo SUCCESS! \n"|| ( echo -e  "Deploy Git Repo Failed! \n"&&export SUC=0&&exit)
    else
        cd blog_hexo_source/.deploy&&echo -e  "Pull Deploy Repo..."&& git  pull  github master&&cd ../..&&echo -e  "Deploy Git Repo SUCCESS! \n"|| ( cd .. &&echo -e  "Deploy Git Repo Failed! \n"&&export SUC=0&&exit)
fi
CURRENT=`pwd`
BASENAME=`basename "$CURRENT"`
if [ "$BASENAME"x = ".deploy"x ];then
        cd ../..
        echo `pwd`
fi

if [ ! -e  blog_hexo_source/.git/hooks/pre-commit ]; then
        echo -e "Start Link Git Hooks \n"&&ln -s ../../hooks/pre-commit blog_hexo_source/.git/hooks/
fi
if  [  -f  blog_hexo_source/hooks/post-clone ]   ; then
        echo -e  "Running Post Clone Hooks\n"&&chmod u+x blog_hexo_source/hooks/post-clone &&cd blog_hexo_source&&exec hooks/post-clone&&echo -e   "post-clone SUCCESS!\n" && git status ||echo -e  "post-clone Failed!\n" 
fi


