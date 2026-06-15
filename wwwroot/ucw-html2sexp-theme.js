(function () {
  var SUN = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>';
  var MOON = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>';

  var s = localStorage.getItem('mrp-theme');
  if (s) document.documentElement.setAttribute('data-theme', s);

  function cur() {
    return document.documentElement.getAttribute('data-theme') ||
      (matchMedia('(prefers-color-scheme:dark)').matches ? 'dark' : 'light');
  }

  window.mrpToggleTheme = function () {
    var n = cur() === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', n);
    localStorage.setItem('mrp-theme', n);
    document.querySelectorAll('.mrp-theme-btn').forEach(function (el) {
      el.innerHTML = n === 'dark' ? SUN : MOON;
    });
  };

  // Run FN once the DOM is parsed — immediately if it already is, so a
  // cached/async script load that executes after DOMContentLoaded still injects
  // the toggle (a bare listener would silently miss the already-fired event).
  function whenReady(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  whenReady(function () {
    document.querySelectorAll('header nav>ul:last-child').forEach(function (ul) {
      var li = document.createElement('li');
      var a = document.createElement('a');
      a.href = '#';
      a.className = 'mrp-theme-btn';
      a.setAttribute('aria-label', 'Toggle light/dark mode');
      a.onclick = function (e) { e.preventDefault(); window.mrpToggleTheme(); };
      a.innerHTML = cur() === 'dark' ? SUN : MOON;
      li.appendChild(a);
      // Place the toggle just before the hamburger menu so the order is
      // New task · theme toggle · ☰ (menu in the far-right corner).
      var menu = ul.querySelector('details.app-menu');
      var menuLi = menu && menu.closest('li');
      if (menuLi) ul.insertBefore(li, menuLi);
      else ul.appendChild(li);
    });
  });
})();
