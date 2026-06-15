;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-
(asdf:defsystem :ucw-html2sexp-test
  :name "ucw-html2sexp-test"
  :description "Tests for ucw-html2sexp"
  :components ((:module "test"
                :components ((:file "package")
                             (:file "test" :depends-on ("package")))))
  :depends-on (:ucw-html2sexp :html2sexp :myam))
