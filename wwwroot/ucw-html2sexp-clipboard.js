// Copy-to-clipboard buttons:
//   <button class="copy-btn" data-copy-target="ELEMENT_ID">
//     ... <span class="copy-btn-label">Copy</span></button>
// Clicking copies the textContent of #ELEMENT_ID and briefly shows "Copied!".
(function () {
  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); resolve(); }
      catch (e) { reject(e); }
      finally { document.body.removeChild(ta); }
    });
  }

  // Run FN once the DOM is parsed — immediately if it already is, so a
  // cached/async script load that executes after DOMContentLoaded still wires
  // up the copy buttons (a bare listener would miss the already-fired event).
  function whenReady(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  whenReady(function () {
    document.querySelectorAll('.copy-btn[data-copy-target]').forEach(function (btn) {
      var label = btn.querySelector('.copy-btn-label');
      var orig = label ? label.textContent : null;
      btn.addEventListener('click', function () {
        var el = document.getElementById(btn.getAttribute('data-copy-target'));
        if (!el) return;
        copyText(el.textContent).then(function () {
          btn.classList.add('copied');
          if (label) label.textContent = 'Copied!';
          setTimeout(function () {
            btn.classList.remove('copied');
            if (label) label.textContent = orig;
          }, 1500);
        });
      });
    });
  });
})();
