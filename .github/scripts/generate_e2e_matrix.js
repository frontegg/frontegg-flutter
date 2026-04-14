#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");

// One scenario per shard: pairs of heavy tests (login + 240s token waits) still
// exceeded 90m; isolating avoids a single stuck/hung test blocking a whole pair.
const MAX_TESTS_PER_SHARD = 1;

const ROOT = path.resolve(__dirname, "../..");
const CONFIG = {
  catalog: path.join(ROOT, "embedded/e2e/scenario-catalog.json"),
  testSources: [
    path.join(ROOT, "embedded/integration_test/e2e/embedded_e2e_test.dart"),
  ],
};

function readCatalogMethods(catalogPath) {
  const raw = JSON.parse(fs.readFileSync(catalogPath, "utf-8"));
  const entries = raw.tests || raw.scenarios || [];
  return entries
    .map((entry) => entry.method)
    .filter((method) => typeof method === "string" && method.length > 0);
}

function readDartTestMethods(testSources) {
  const methods = new Set();
  const re = /e2ePatrolTest\(\s*'(test[A-Za-z0-9_]+)'/gm;
  for (const sourcePath of testSources) {
    const source = fs.readFileSync(sourcePath, "utf-8");
    for (const match of source.matchAll(re)) {
      methods.add(match[1]);
    }
  }
  return [...methods];
}

function parseExcludeList(raw) {
  return new Set(
    String(raw || "")
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean),
  );
}

function validateCatalog(catalogMethods, sourceMethods) {
  const catalogSet = new Set(catalogMethods);
  const sourceSet = new Set(sourceMethods);
  const catalogOnly = catalogMethods.filter((m) => !sourceSet.has(m));
  const sourceOnly = sourceMethods.filter((m) => !catalogSet.has(m));
  if (catalogOnly.length === 0 && sourceOnly.length === 0) return;
  const problems = [];
  if (catalogOnly.length) problems.push(`catalog-only: ${catalogOnly.join(", ")}`);
  if (sourceOnly.length) problems.push(`uncatalogued: ${sourceOnly.join(", ")}`);
  throw new Error(`embedded E2E catalog drift: ${problems.join("; ")}`);
}

/** When building a platform-specific shard list, excluded tests stay in the repo/catalog but are omitted from the matrix. */
function validateShardMethods(shardMethods, sourceMethods) {
  const sourceSet = new Set(sourceMethods);
  const unknown = shardMethods.filter((m) => !sourceSet.has(m));
  if (unknown.length) {
    throw new Error(`shard methods not found in Dart sources: ${unknown.join(", ")}`);
  }
}

function splitIntoShards(items, shardCount) {
  const shards = Array.from({ length: shardCount }, () => []);
  items.forEach((item, i) => shards[i % shardCount].push(item));
  return shards;
}

function main() {
  const parsed = parseInt(process.env.INPUT_SHARD_COUNT || "1", 10);
  const shardCount = Number.isNaN(parsed) ? 1 : Math.max(1, parsed);

  const catalogMethods = readCatalogMethods(CONFIG.catalog);
  const exclude = parseExcludeList(process.env.INPUT_EXCLUDE_METHODS);
  const methods = exclude.size
    ? catalogMethods.filter((m) => !exclude.has(m))
    : catalogMethods;
  const sourceMethods = readDartTestMethods(CONFIG.testSources);
  if (exclude.size) {
    for (const m of exclude) {
      if (!catalogMethods.includes(m)) {
        throw new Error(`INPUT_EXCLUDE_METHODS: not in catalog: ${m}`);
      }
    }
    validateShardMethods(methods, sourceMethods);
  } else {
    validateCatalog(catalogMethods, sourceMethods);
  }

  const autoShards = Math.ceil(methods.length / MAX_TESTS_PER_SHARD);
  const effectiveShardCount =
    shardCount > 1 ? Math.min(shardCount, methods.length || 1) : Math.max(1, autoShards);

  const include = [];
  if (effectiveShardCount <= 1 || methods.length === 0) {
    include.push({
      "shard-index": 1,
      "shard-total": 1,
      "test-methods": "",
    });
  } else {
    const shards = splitIntoShards(methods, effectiveShardCount);
    shards.forEach((shard, i) => {
      include.push({
        "shard-index": i + 1,
        "shard-total": effectiveShardCount,
        "test-methods": shard.join(","),
      });
    });
  }

  const matrix = JSON.stringify({ include });
  const outputFile = process.env.GITHUB_OUTPUT;
  if (outputFile) {
    fs.appendFileSync(outputFile, `matrix=${matrix}\n`);
  }
  console.log(matrix);
}

main();
