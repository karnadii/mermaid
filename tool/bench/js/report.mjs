// Merges the native Dart results and the JS results into one Markdown table.
//   node report.mjs <dart_aot.json> <js.json>
import { readFileSync } from 'node:fs';

const [dartPath, jsPath] = process.argv.slice(2);
const dart = JSON.parse(readFileSync(dartPath, 'utf8'));
const js = JSON.parse(readFileSync(jsPath, 'utf8'));

const columns = [
  ['mermaid_core AOT', dart],
  ['pele Node', js.node.pele],
  ...Object.entries(js.browser).map(([k, v]) => [`${k} Chromium`, v]),
];
const fmt = (r) =>
  !r ? '–' : (r.ms < 1 ? r.ms.toFixed(3) : r.ms.toFixed(1)) + (r.rendered === r.diagrams ? '' : ` (${r.rendered}/${r.diagrams})`);

const cases = dart.map((r) => r.case);
const lines = [
  `| case | ${columns.map(([n]) => n).join(' | ')} |`,
  `| --- |${columns.map(() => ' ---: |').join('')}`,
];
for (const c of cases) {
  lines.push(`| ${c} | ${columns.map(([, rows]) => fmt(rows.find((r) => r.case === c))).join(' | ')} |`);
}
console.log('Median ms per pass over all diagrams of the case.\n');
console.log(lines.join('\n'));
