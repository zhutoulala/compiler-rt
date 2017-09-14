//===- FuzzerMerge.cpp - merging corpora ----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Merging corpora.
//===----------------------------------------------------------------------===//

#include "FuzzerMerge.h"
#include "FuzzerIO.h"
#include "FuzzerInternal.h"
#include "FuzzerTracePC.h"
#include "FuzzerUtil.h"

#include <fstream>
#include <iterator>
#include <set>
#include <sstream>

namespace fuzzer {
	

// Inner process. May crash if the target crashes.
void Fuzzer::CrashResistantMergeInternalStep(const std::string &CFPath) {
  return;
}

// Outer process. Does not call the target code and thus sohuld not fail.
void Fuzzer::CrashResistantMerge(const Vector<std::string> &Args,
                                 const Vector<std::string> &Corpora,
                                 const char *CoverageSummaryInputPathOrNull,
                                 const char *CoverageSummaryOutputPathOrNull) {
  return;
}

} // namespace fuzzer
