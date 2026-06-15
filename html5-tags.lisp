;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

;;; HTML5 semantic elements for ucw-html2sexp, defined in the app's own tags
;;; package (:<h2s) so they don't pollute IT.BESE.YACLML.TAGS. Pico CSS styles
;;; header/nav/main; the theme toggle (theme.js) attaches to `header nav>ul`.
;;; Usage: (<h2s:header ...), (<h2s:nav ...), (<h2s:main ...).

(in-package :<h2s)

(it.bese.yaclml::def-html-tag header  :core :event :i18n)
(it.bese.yaclml::def-html-tag nav     :core :event :i18n)
(it.bese.yaclml::def-html-tag main    :core :event :i18n)
(it.bese.yaclml::def-html-tag section :core :event :i18n)
(it.bese.yaclml::def-html-tag footer  :core :event :i18n)
(it.bese.yaclml::def-html-tag article :core :event :i18n)
