// Bridges between the Jaspr page, mermaid.js and Pele (CDN) and the embedded
// Flutter build of mermaid dart.
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';

// Network-first service worker so a returning visitor never runs a stale
// cached build (the bundles have stable filenames). Registered relative to
// this module, so it scopes correctly under a project-pages subpath too.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register(new URL('sw.js', import.meta.url))
    .catch((e) => console.warn('service worker registration failed:', e));
}

mermaid.initialize({ startOnLoad: false, theme: 'default' });

// Register the ELK layout loader so mermaid.js honours `layout: elk` (it ships
// dagre only by default). Best-effort: a failed import must not break the page.
try {
  const elk = await import(
    'https://cdn.jsdelivr.net/npm/@mermaid-js/layout-elk@0/dist/mermaid-layout-elk.esm.min.mjs'
  );
  mermaid.registerLayoutLoaders(elk.default ?? elk);
} catch (e) {
  console.warn('mermaid.js ELK layout loader unavailable:', e);
}

// Pele (https://pele.run), a lightweight Mermaid-to-SVG renderer, as a third
// reference, pinned to an exact version. Not awaited here: the bridge
// functions below must exist before the page first renders. A failed import
// leaves the other panes working.
const pele = import('https://cdn.jsdelivr.net/npm/pele@1.6.0/dist/pele.js').catch((e) => {
  console.warn('Pele unavailable:', e);
  return null;
});

let seq = 0;

window.renderMermaidJs = async (el, source) => {
  try {
    const { svg } = await mermaid.render(`mmdjs${++seq}`, source);
    el.innerHTML = svg;
  } catch (e) {
    el.innerHTML = `<pre style="color:#b00020;white-space:pre-wrap">${String(e)}</pre>`;
    // mermaid.render leaves a dangling error element behind on failure.
    document.getElementById(`dmmdjs${seq}`)?.remove();
  }
};

let peleSeq = 0;

window.renderPele = async (el, source) => {
  const seq = ++peleSeq;
  const lib = await pele;
  // A newer edit may have rendered while the import was pending.
  if (seq !== peleSeq) return;
  if (!lib) {
    el.innerHTML = '<pre style="color:#b00020">Pele failed to load.</pre>';
    return;
  }
  try {
    el.innerHTML = lib.render(source).svg;
  } catch (e) {
    el.innerHTML = `<pre style="color:#b00020;white-space:pre-wrap">${String(e)}</pre>`;
  }
};

// The Flutter view itself is mounted by jaspr_flutter_embed (FlutterEmbedView).
// We only feed it source: __mermaidDartInitialSource is read by the embed at
// boot, and render() (published by the embed once booted) pushes live edits.
window.__mermaidDartInitialSource = '';

window.updateMermaidDart = (source) => {
  window.__mermaidDartInitialSource = source;
  window.mermaidDartEmbed?.render(source);
};

// Promotes the embedded Flutter pane to a full-page overlay. An in-Flutter
// dialog is clipped to the (small) embedded view, so the host does this on the
// page: toggle a CSS class on the pane and add a DOM close button + Esc.
window.mermaidDartToggleFullscreen = () => {
  const pane = document.getElementById('pane-mermaid-dart');
  if (!pane) return;
  const on = pane.classList.toggle('mermaid-fullscreen');
  let close = document.getElementById('mermaid-fs-close');
  if (on) {
    if (!close) {
      close = document.createElement('button');
      close.id = 'mermaid-fs-close';
      close.type = 'button';
      close.textContent = '✕ Close';
      close.addEventListener('click', () => window.mermaidDartToggleFullscreen());
      document.body.appendChild(close);
    }
    window.__mermaidFsEsc = (e) => {
      if (e.key === 'Escape') window.mermaidDartToggleFullscreen();
    };
    document.addEventListener('keydown', window.__mermaidFsEsc);
  } else {
    close?.remove();
    if (window.__mermaidFsEsc) {
      document.removeEventListener('keydown', window.__mermaidFsEsc);
      window.__mermaidFsEsc = null;
    }
  }
};

// The bridge functions exist from here on. The page may render before this
// module has finished loading its imports, so it waits for this signal.
window.__mermaidBridgeReady = true;
window.dispatchEvent(new Event('mermaid-bridge-ready'));
