;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-
(in-package :ucw-html2sexp-test)

(defsuite* :ucw-html2sexp-test)

;;; The core logic worth testing is the "unfold": html2sexp wraps output in a
;;; full (:html (:head "") (:body . FORMS)) document, and we strip that down to
;;; just the pasted FORMS. (The UI itself is GitHub-OAuth-gated in the bundle, so
;;; this is a unit test of the pure conversion+unfold rather than a browser e2e.)

(deftest unfold-strips-document-wrapper
  (is (equal '((:p "hello") (:blah ""))
             (ucw-html2sexp::h2s-unfold
              (html2sexp:html2cl-who "<p>hello</p><blah></blah>")))))

(deftest unfold-single-element
  (is (equal '((:div :class "x" "hi"))
             (ucw-html2sexp::h2s-unfold
              (html2sexp:html2cl-who "<div class='x'>hi</div>")))))

(deftest unfold-bare-text
  (is (equal (list (format nil "foo~%bar"))
             (ucw-html2sexp::h2s-unfold
              (html2sexp:html2cl-who (format nil "foo~%bar"))))))

(deftest unfold-passthrough-non-document
  (is (equal '((:p "x")) (ucw-html2sexp::h2s-unfold '(:p "x")))))
