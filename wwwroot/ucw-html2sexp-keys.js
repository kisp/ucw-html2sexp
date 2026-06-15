// Ctrl+Enter (or Cmd+Enter) in the HTML textarea converts immediately, instead
// of waiting for the up-autosubmit debounce. It triggers the active dialect's
// button (.h2s-fmt-active, set server-side from fmt-of), falling back to cl-who.
document.addEventListener('keydown', function (e) {
  if (!(e.ctrlKey || e.metaKey) || e.key !== 'Enter') return;
  var ta = e.target.closest && e.target.closest('#h2s-html');
  if (!ta) return;
  e.preventDefault();
  var btn = document.querySelector('.h2s-fmt-active') ||
            document.querySelector('.h2s-fmt-who');
  if (btn) btn.click();
});
