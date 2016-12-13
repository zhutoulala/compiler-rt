// Tests trace pc guard coverage collection.
//
// REQUIRES: has_sancovcc
// XFAIL: tsan,arm,aarch64
//
// RUN: DIR=%t_workdir
// RUN: rm -rf $DIR
// RUN: mkdir -p $DIR
// RUN: cd $DIR
// RUN: %clangxx -O0 -fsanitize-coverage=trace-pc-guard %s -ldl -o %t
// RUN: %env_tool_opts=coverage=1 %t 2>&1 | FileCheck %s
// RUN: %sancovcc  -covered-functions -strip_path_prefix=TestCases/ *.sancov %t 2>&1 | \
// RUN:   FileCheck --check-prefix=CHECK-SANCOV %s
// RUN: rm -rf $DIR

#include <stdio.h>

int foo() {
  fprintf(stderr, "foo\n");
  return 1;
}

int main() {
  fprintf(stderr, "main\n");
  foo();
  foo();
}

// CHECK: main
// CHECK-NEXT: foo
// CHECK-NEXT: foo
// CHECK-NEXT: SanitizerCoverage: ./sanitizer_coverage_trace_pc_guard.{{.*}}.sancov 2 PCs written
//
// CHECK-SANCOV: sanitizer_coverage_trace_pc_guard.cc:18 foo
// CHECK-SANCOV-NEXT: sanitizer_coverage_trace_pc_guard.cc:23 main
