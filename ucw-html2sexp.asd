;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(asdf:defsystem :ucw-html2sexp
  :name "ucw-html2sexp"
  :description "A UCW frontend to html2sexp: paste HTML, convert to cl-who / cl-markup / yaclml s-expressions."
  :author "Kilian Sprotte <kilian.sprotte@gmail.com>"
  :version #.(with-open-file
                 (vers (merge-pathnames "version.lisp-expr" *load-truename*))
               (read vers))
  :components ((:static-file "version" :pathname #p"version.lisp-expr")
               (:file "package")
               (:file "html5-tags" :depends-on ("package"))
               (:file "web" :depends-on ("package" "html5-tags")))
  :depends-on (:kucw
               :ucw-apps-sprotte-common
               :ucw-github-auth
               :html2sexp))
