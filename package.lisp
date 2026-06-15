;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

;;; define-common-package gives the standard app package (uses ucw / arnesi /
;;; yaclml / ucw-apps-sprotte-common) and exports START-/STOP-/RESTART- and
;;; *...-APPLICATION*.
(ucw-apps-sprotte-common:define-common-package :ucw-html2sexp
  :application-name #:ucw-html2sexp)
