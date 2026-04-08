#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");

function main() {
  const args = process.argv.slice(2);
  let artifactsDir = "";
  let summaryFile = "";

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--artifacts-dir" && args[i + 1]) artifactsDir = args[++i];
    if (args[i] === "--summary" && args[i + 1]) summaryFile = args[++i];
  }

  if (!artifactsDir) {
    console.error("Usage: combine_e2e_summary.js --artifacts-dir <dir> --summary <file>");
    process.exit(1);
  }

  const lines = ["# Flutter Embedded E2E Summary\n"];
  let totalTests = 0;
  let totalPassed = 0;
  let totalFailed = 0;

  if (fs.existsSync(artifactsDir)) {
    const entries = fs.readdirSync(artifactsDir);
    for (const entry of entries.sort()) {
      const entryPath = path.join(artifactsDir, entry);
      if (!fs.statSync(entryPath).isDirectory()) continue;

      lines.push(`## ${entry}\n`);

      const xmlFiles = (fs.readdirSync(entryPath) || []).filter((f) => f.endsWith(".xml"));
      if (xmlFiles.length === 0) {
        lines.push("No JUnit XML reports found.\n");
        continue;
      }

      for (const xmlFile of xmlFiles) {
        const content = fs.readFileSync(path.join(entryPath, xmlFile), "utf-8");
        const testsMatch = content.match(/tests="(\d+)"/);
        const failuresMatch = content.match(/failures="(\d+)"/);
        const errorsMatch = content.match(/errors="(\d+)"/);

        const tests = testsMatch ? parseInt(testsMatch[1], 10) : 0;
        const failures = (failuresMatch ? parseInt(failuresMatch[1], 10) : 0) +
                         (errorsMatch ? parseInt(errorsMatch[1], 10) : 0);
        const passed = tests - failures;

        totalTests += tests;
        totalPassed += passed;
        totalFailed += failures;

        const emoji = failures > 0 ? "❌" : "✅";
        lines.push(`${emoji} **${xmlFile}**: ${passed}/${tests} passed\n`);
      }
    }
  }

  lines.unshift("");
  lines.unshift(`**Total**: ${totalPassed}/${totalTests} passed, ${totalFailed} failed`);
  lines.unshift("");

  const output = lines.join("\n");

  if (summaryFile) {
    fs.writeFileSync(summaryFile, output);
    console.log(`Summary written to ${summaryFile}`);
  } else {
    console.log(output);
  }
}

main();
