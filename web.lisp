;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :ucw-html2sexp)

;;;; * A colorizing s-expression printer
;;;
;;; html2sexp returns plain Lisp s-exps. We render them to colored, indented
;;; HTML by walking the tree directly (rather than print-then-tokenize), which
;;; lets us print yaclml tag symbols as <:name so the yaclml output is actually
;;; valid yaclml, not the bare it.bese.yaclml.tags:name the standard printer
;;; gives. The colors are .tok-* spans styled in screen.css with the Pico
;;; palette, so they follow the light/dark toggle. Copy-to-clipboard grabs the
;;; element's textContent, which is exactly the plain s-exp (spans add no chars).

(defparameter +yaclml-tags-package+ (find-package :it.bese.yaclml.tags)
  "Symbols here are yaclml tags; we print them as <:name.")

(defparameter +flat-threshold+ 60
  "A list whose flat rendering is at most this many chars stays on one line.")

(defun h2s-escape (text)
  "HTML-escape TEXT."
  (with-output-to-string (s)
    (loop for c across text do
      (case c
        (#\< (write-string "&lt;" s))
        (#\> (write-string "&gt;" s))
        (#\& (write-string "&amp;" s))
        (#\" (write-string "&quot;" s))
        (t (write-char c s))))))

(defun h2s-token (out class text)
  "Write one colored token (TEXT escaped) to OUT."
  (format out "<span class=\"~A\">~A</span>" class (h2s-escape text)))

(defun h2s-atom (atom)
  "Return (values text class) for an atom."
  (typecase atom
    (string (values (format nil "~S" atom) "tok-string"))
    (keyword (values (format nil ":~(~A~)" (symbol-name atom)) "tok-keyword"))
    (symbol (cond
              ((eq (symbol-package atom) +yaclml-tags-package+)
               (values (format nil "<:~(~A~)" (symbol-name atom)) "tok-tag"))
              ((string= (symbol-name atom) "@")
               (values "@" "tok-tag"))
              (t (values (format nil "~(~A~)" (symbol-name atom)) "tok-symbol"))))
    (number (values (princ-to-string atom) "tok-number"))
    (t (values (princ-to-string atom) "tok-symbol"))))

(defun h2s-flat-length (node)
  "Rough char length of NODE rendered on one line."
  (typecase node
    (string (+ 2 (length node)))
    (symbol (+ 2 (length (symbol-name node))))
    (cons (+ 1 (length node)            ; parens + inter-element spaces
             (reduce #'+ node :key #'h2s-flat-length :initial-value 0)))
    (t (length (princ-to-string node)))))

(defun h2s-emit (out node indent)
  (if (consp node)
      (h2s-emit-list out node indent)
      (multiple-value-bind (text class) (h2s-atom node)
        (h2s-token out class text))))

(defun h2s-emit-list (out node indent)
  (h2s-token out "tok-paren" "(")
  (cond
    ((<= (h2s-flat-length node) +flat-threshold+)
     (loop for (x . rest) on node do
       (h2s-emit out x indent)
       (when rest (write-char #\Space out))))
    (t
     ;; head inline, remaining elements each on their own indented line
     (let ((child-indent (1+ indent)))
       (h2s-emit out (first node) child-indent)
       (dolist (x (rest node))
         (write-char #\Newline out)
         (dotimes (i child-indent) (write-char #\Space out))
         (h2s-emit out x child-indent)))))
  (h2s-token out "tok-paren" ")"))

(defun colorize-forms (forms)
  "Render a list of top-level FORMS as colored HTML, one per line."
  (with-output-to-string (out)
    (loop for (f . rest) on forms do
      (h2s-emit out f 0)
      (when rest (write-char #\Newline out)))))

;;;; * Unfolding the html2sexp document wrapper
;;;
;;; html2sexp always wraps its output in a full document:
;;;   (:html (:head "") (:body . FORMS))   ; cl-who / cl-markup
;;;   (html (head "") (body . FORMS))      ; yaclml (tag symbols)
;;; The user pasted a fragment, so we strip that wrapper and return just FORMS -
;;; the s-exps of what they actually pasted.

(defun h2s-tag-name= (sym name)
  "True if SYM names tag NAME, case-insensitively. Works for both the keyword
:body and the yaclml tag symbol body."
  (and (symbolp sym) (string-equal (symbol-name sym) name)))

(defun h2s-unfold (sexp)
  "Strip the (:html (:head ...) (:body . FORMS)) document wrapper html2sexp adds
and return FORMS as a list. If SEXP is not that wrapper, return (list SEXP)."
  (if (and (consp sexp) (h2s-tag-name= (first sexp) "html"))
      (let ((body (find-if (lambda (x) (and (consp x) (h2s-tag-name= (first x) "body")))
                           (rest sexp))))
        (if body (rest body) (list sexp)))
      (list sexp)))

;;;; * The application

(define-common-application #:ucw-html2sexp
  :package :ucw-html2sexp
  :system :ucw-html2sexp
  :url-prefix "/html2sexp/")

(defparameter +h2s-examples+
  '(("Simple div"          . "<div class=\"greeting\">Hello, world!</div>")
    ("Nested + attributes" . "<article id=\"post\"><h1>Hi</h1><p>A <a href=\"/x\">link</a> and <b>bold</b> text.</p></article>")
    ("List"                . "<ul><li>one</li><li>two</li><li>three</li></ul>")
    ("Form"                . "<form action=\"/submit\" method=\"post\"><label>Name <input type=\"text\" name=\"n\"></label> <button>Go</button></form>")
    ("Table"               . "<table><thead><tr><th>A</th><th>B</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr></tbody></table>")
    ("Figure + image"      . "<figure><img src=\"cat.jpg\" alt=\"a cat\"><figcaption>A cat.</figcaption></figure>")
    ("SVG"                 . "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><circle cx=\"12\" cy=\"12\" r=\"10\" fill=\"gold\"/><path d=\"M8 13a4 4 0 0 0 8 0\" stroke=\"black\" fill=\"none\"/></svg>"))
  "Prepared HTML snippets offered in the examples dropdown.")

(defcomponent ucw-html2sexp-window (simple-window-component)
  ((html :initform "" :accessor html-of)        ; the pasted HTML
   (fmt :initform :cl-who :accessor fmt-of)      ; last format converted to
   (result :initform nil :accessor result-of)    ; colorized HTML string, or NIL
   (err :initform nil :accessor err-of)          ; error message, or NIL
   (example :initform "" :accessor example-of))  ; examples-dropdown value
  (:default-initargs
   :title "html2sexp"
   :doctype nil
   :stylesheet (list "pico.min.css" "screen.css")
   :javascript (list (list :src "ucw-html2sexp-theme.js")
                     (list :src "ucw-html2sexp-clipboard.js")
                     (list :src "ucw-html2sexp-keys.js"))))

(defun h2s-html->sexp (html fmt)
  "Parse HTML to a single document s-exp in FMT (:cl-who/:cl-markup/:yaclml)."
  (ecase fmt
    (:cl-who (html2sexp:html2cl-who html))
    (:cl-markup (html2sexp:html2cl-markup html))
    (:yaclml (html2sexp:html2yaclml html))))

(defun h2s-colorize-html (html fmt)
  "Full pipeline: HTML string -> colorized HTML of the unfolded forms. May
signal - e.g. yaclml predates HTML5 and has no figcaption/header/... tags, so
converting such input to :yaclml signals an undefined-tag error (kucw-yaclml#4),
which h2s-convert catches into the error pane."
  (colorize-forms (h2s-unfold (h2s-html->sexp html fmt))))

(defun h2s-convert (self fmt)
  "Convert the pasted HTML to FMT and store the colorized result (or an error).
The (:html (:head ...) (:body ...)) wrapper is unfolded to just the pasted forms."
  (setf (fmt-of self) fmt)
  (handler-case
      (setf (result-of self) (h2s-colorize-html (or (html-of self) "") fmt)
            (err-of self) nil)
    (error (e)
      (setf (result-of self) nil
            (err-of self) (princ-to-string e)))))

(defun h2s-load-example (self)
  "Load the chosen example into the textarea and convert it to the current format."
  (let ((html (example-of self)))
    (when (and html (plusp (length html)))
      (setf (html-of self) html)
      (h2s-convert self (fmt-of self)))))

(defun h2s-home-url ()
  "The app's mount prefix (e.g. /html2sexp/) - the title links here to return
to a fresh home page."
  (ucw::application.url-prefix (ucw::context.application *context*)))

(defun h2s-fmt-class (self base fmt)
  "BASE plus an active marker when FMT is the window's current format. The marker
class lets screen.css highlight the active dialect and lets keys.js know which
button Ctrl+Enter should trigger."
  (if (eq (fmt-of self) fmt)
      (concatenate 'string base " h2s-fmt-active")
      base))

(defmethod render ((self ucw-html2sexp-window))
  (<:header :class "container"
    (<:nav
      (<:ul (<:li (<:a :href (h2s-home-url) (<:strong "html2sexp")))
            (<:li (<:small "HTML to Lisp s-expressions")))
      ;; theme.js appends the light/dark toggle to this last <ul>.
      (<:ul)))
  (<:main :class "container"
    (<:p "Paste HTML and convert it to a Lisp s-expression in "
         (<:code "cl-who") ", " (<:code "cl-markup") " or " (<:code "yaclml")
         " notation.")
    ;; #h2s-app is the Unpoly target: a format button (or the debounced
    ;; up-autosubmit on the textarea) swaps just this fragment (up-scroll=false),
    ;; so the page does not jump back to the top. The form's default :action
    ;; converts in the CURRENT dialect (fmt-of) - that is what up-autosubmit and
    ;; Ctrl+Enter trigger; the buttons override it to switch dialect.
    (<:div :id "h2s-app"
      (<ucw:form :action (h2s-convert self (fmt-of self))
        (@ :up-submit "true" :up-target "#h2s-app" :up-scroll "false")
        (<:p (<:label "Try an example: "
               (<ucw:select :accessor (example-of self) :on-change (h2s-load-example self)
                 (<ucw:option :value "" "- choose -")
                 (dolist (ex +h2s-examples+)
                   (<ucw:option :value (cdr ex) (<:as-html (car ex)))))))
        ;; up-autosubmit re-converts ~600ms after you stop typing; the stable id
        ;; lets Unpoly keep focus + caret across the fragment swap.
        (<ucw:textarea :accessor (html-of self) :rows "10"
                       (@ :id "h2s-html"
                          :up-autosubmit "true"
                          :up-watch-delay "600"
                          :up-watch-event "input"
                          :placeholder "<div class=\"greeting\">hello</div>  (Ctrl+Enter to convert now)"
                          :spellcheck "false"
                          :style "width:100%;font-family:monospace"))
        (<:p
         (<ucw:input :type "submit" :class (h2s-fmt-class self "h2s-fmt-who" :cl-who)
                     :action (h2s-convert self :cl-who) :value "cl-who")
         " "
         (<ucw:input :type "submit" :class (h2s-fmt-class self "h2s-fmt-markup" :cl-markup)
                     :action (h2s-convert self :cl-markup) :value "cl-markup")
         " "
         (<ucw:input :type "submit" :class (h2s-fmt-class self "h2s-fmt-yaclml" :yaclml)
                     :action (h2s-convert self :yaclml) :value "yaclml")))
      (when (err-of self)
        (<:p :class "h2s-error" (@ :role "alert") (<:as-html (err-of self))))
      (when (result-of self)
        (<:div :class "h2s-result-wrap"
          (<:div :class "h2s-result-head"
            (<:span :class "h2s-fmt-label" (<:as-html (format nil "~(~A~)" (fmt-of self))))
            (<:button :class "copy-btn" (@ :type "button" :data-copy-target "h2s-result")
              (<:span :class "copy-btn-label" "Copy")))
          (<:pre :id "h2s-result"
            (<:code :class "h2s-code" (<:as-is (result-of self)))))))))
