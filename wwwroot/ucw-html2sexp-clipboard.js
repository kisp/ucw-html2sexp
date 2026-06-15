// Copy-to-clipboard via event DELEGATION, so it keeps working for the copy
// button that Unpoly swaps into #h2s-app after each conversion (a per-button
// listener wired at load would not catch swapped-in buttons):
//   <button class="copy-btn" data-copy-target="ID">..<span class="copy-btn-label">Copy</span></button>
(function () {
  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      var ta = document.createElement('textarea');
      ta.value = text; ta.style.position = 'fixed'; ta.style.opacity = '0';
      document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy'); resolve(); }
      catch (e) { reject(e); }
      finally { document.body.removeChild(ta); }
    });
  }
  document.addEventListener('click', function (e) {
    var btn = e.target.closest && e.target.closest('.copy-btn[data-copy-target]');
    if (!btn) return;
    var el = document.getElementById(btn.getAttribute('data-copy-target'));
    if (!el) return;
    copyText(el.textContent).then(function () {
      var label = btn.querySelector('.copy-btn-label');
      var orig = label ? label.textContent : null;
      btn.classList.add('copied');
      if (label) label.textContent = 'Copied!';
      setTimeout(function () {
        btn.classList.remove('copied');
        if (label) label.textContent = orig;
      }, 1500);
    });
  });
})();
