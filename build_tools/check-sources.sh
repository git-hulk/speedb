#!/usr/bin/env bash
# Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
#
# Check for some simple mistakes that should prevent commit or push

BAD=""

git grep -n 'namespace rocksdb' -- '*.[ch]*'
if [ "$?" != "1" ]; then
  echo "^^^^^ Do not hardcode namespace rocksdb. Use ROCKSDB_NAMESPACE"
  BAD=1
fi

git grep -n -i 'nocommit' -- ':!build_tools/check-sources.sh'
if [ "$?" != "1" ]; then
  echo "^^^^^ Code was not intended to be committed"
  BAD=1
fi

git grep -n 'include <rocksdb/' -- ':!build_tools/check-sources.sh'
if [ "$?" != "1" ]; then
  echo '^^^^^ Use double-quotes as in #include "rocksdb/something.h"'
  BAD=1
fi

git grep -n 'include "include/rocksdb/' -- ':!build_tools/check-sources.sh'
if [ "$?" != "1" ]; then
  echo '^^^^^ Use #include "rocksdb/something.h" instead of #include "include/rocksdb/something.h"'
  BAD=1
fi

git grep -n 'using namespace' -- ':!build_tools' ':!docs' \
    ':!third-party/folly/folly/lang/Align.h' \
    ':!third-party/gtest-1.8.1/fused-src/gtest/gtest.h' \
    ':!examples/speedb_with_ttl_example.cc' \
    ':!examples/enable_speedb_features_example.cc' \
    ':!examples/on_thread_start_callback_example.cc'
if [ "$?" != "1" ]; then
  echo '^^^^ Do not use "using namespace"'
  BAD=1
fi

git grep -n -P "[\x80-\xFF]" -- ':!docs' ':!*.md' ':!*.gif'
if [ "$?" != "1" ]; then
  echo '^^^^ Use only ASCII characters in source files'
  BAD=1
fi

git grep -Li -E "license|copyright" -- ':*speed*.cc' ':*spdb*.h' ':*speed*.h' ':*spdb*.cc'
if [ "$?" != "1" ]; then
  echo '^^^^ Source files do not contain license'
  BAD=1
fi

if [ "$BAD" ]; then
  exit 1
fi
