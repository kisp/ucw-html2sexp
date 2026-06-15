;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

;;; HTML5 semantic tags (header/nav/main/...) live in this app-local tags
;;; package (nickname :<h2s) since yaclml's global tag package predates HTML5.
;;; Used as <h2s:header, <h2s:nav, ... in web.lisp.
(defpackage :ucw-html2sexp.tags
  (:nicknames :<h2s)
  (:use :common-lisp :it.bese.yaclml)
  (:export #:header #:nav #:main #:section #:footer #:article))

;;; define-common-package gives the standard app package (uses ucw / arnesi /
;;; yaclml / ucw-apps-sprotte-common) and exports START-/STOP-/RESTART- and
;;; *...-APPLICATION*.
(ucw-apps-sprotte-common:define-common-package :ucw-html2sexp
  :application-name #:ucw-html2sexp)
