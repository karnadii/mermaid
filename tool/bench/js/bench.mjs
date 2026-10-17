// Times Pele on Node, and Pele, mermaid.js and dart2js mermaid_core in headless
// Chromium, on the corpus written by `bin/bench.dart --corpus`. The timing loop
// is the one in Pele's scripts/bench.mjs: one warm-up pass, then repeat for a
// 300 ms budget (5..2000 samples) and report the median.
//
//   node bench.mjs <corpus.json> <dart_bench.js> [--filter text] [--skip-mermaid]
//
// Writes JSON results to stdout: { node: { pele: [...] }, browser: { ... } }.
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { chromium } from 'playwright';
import { render as peleRender } from 'pele';

const require = createRequire(import.meta.url);
const [corpusPath, dartJsPath] = process.argv.slice(2);
const filterAt = process.argv.indexOf('--filter');
const filter = filterAt > 0 ? process.argv[filterAt + 1] : null;
const skipMermaid = process.argv.includes('--skip-mermaid');
const corpus = JSON.parse(readFileSync(corpusPath, 'utf8')).filter(
  (c) => !filter || c.name.includes(filter),
);

// Kept self-contained so it can be sent to the page with toString().
// Browsers coarsen performance.now() to ~0.1 ms, so a sample repeats the pass
// until it takes at least 2 ms and the time is divided by the repeat count.
async function time(fn, inputs) {
  const run = async () => {
    let done = 0;
    for (const src of inputs) {
      try {
        await fn(src);
        done++;
      } catch {
        continue;
      }
    }
    return done;
  };
  const done = await run();
  let reps = 0;
  let t = performance.now();
  while (performance.now() - t < 2) {
    await run();
    reps++;
  }
  let budget = 300;
  const samples = [];
  while (budget > 0 || samples.length < 5) {
    t = performance.now();
    for (let r = 0; r < reps; r++) await run();
    const total = performance.now() - t;
    samples.push(total / reps);
    budget -= total;
    if (samples.length >= 2000) break;
  }
  samples.sort((a, b) => a - b);
  return { ms: samples[samples.length >> 1], done };
}

const log = (...a) => console.error(...a);
const results = { node: { pele: [] }, browser: {} };

log('# Node: pele');
for (const c of corpus) {
  // Pele's render() is synchronous; awaiting a non-promise adds a microtask
  // per diagram, which is noise next to the render cost but kept equal for
  // every engine.
  const { ms, done } = await time((s) => peleRender(s), c.inputs);
  results.node.pele.push({ case: c.name, ms, rendered: done, diagrams: c.inputs.length });
  log(`${c.name.padEnd(48)} ${ms.toFixed(3).padStart(10)} ms`);
}

const browser = await chromium.launch();
const page = await browser.newPage();
page.on('pageerror', (e) => log('page error:', e.message));
await page.setContent('<!doctype html><html><body><div id="host"></div></body></html>');
await page.addScriptTag({ path: require.resolve('pele/global') });
await page.addScriptTag({ path: dartJsPath });
if (!skipMermaid) {
  await page.addScriptTag({ path: require.resolve('mermaid/dist/mermaid.min.js') });
  await page.evaluate(() =>
    window.mermaid.initialize({ startOnLoad: false, securityLevel: 'strict' }),
  );
}
await page.evaluate(`window.__time = ${time.toString()};`);
await page.waitForFunction(() => typeof window.mermaidDartRender === 'function');

const engines = {
  'mermaid_core (dart2js)': '(s) => window.mermaidDartRender(s)',
  pele: '(s) => window.pele.render(s)',
};
if (!skipMermaid) {
  // mermaid.render() needs a unique id per call; it measures text in the DOM.
  engines['mermaid.js'] = '(s) => window.mermaid.render("m" + (window.__n = (window.__n || 0) + 1), s)';
}

for (const [engine, fnSrc] of Object.entries(engines)) {
  log(`# Chromium: ${engine}`);
  results.browser[engine] = [];
  for (const c of corpus) {
    const { ms, done } = await page.evaluate(
      ([fnSrc, inputs]) => window.__time(eval(fnSrc), inputs),
      [fnSrc, c.inputs],
    );
    results.browser[engine].push({ case: c.name, ms, rendered: done, diagrams: c.inputs.length });
    log(`${c.name.padEnd(48)} ${ms.toFixed(3).padStart(10)} ms${done === c.inputs.length ? '' : `  (${done}/${c.inputs.length} rendered)`}`);
  }
}
await browser.close();
console.log(JSON.stringify(results));
