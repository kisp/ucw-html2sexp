# ucw-html2sexp

A small UCW web frontend to [html2sexp](https://github.com/kisp/html2sexp): paste
HTML and convert it to a Lisp s-expression in **cl-who**, **cl-markup**, or
**yaclml** notation. The result pane is syntax-coloured (a tiny server-side
colorizer that follows the Pico light/dark theme) with a copy-to-clipboard
button.

Hosted in the [ucw-apps-sprotte](https://github.com/kisp/ucw-apps-sprotte) bundle
at `/html2sexp/` (kisp-only via GitHub OAuth, like the other bundle apps).

- `nix flake check` builds the app on the pinned SBCL.
- Pico CSS + light/dark toggle + clipboard are shared with ucw-mindful-routine-planner.
