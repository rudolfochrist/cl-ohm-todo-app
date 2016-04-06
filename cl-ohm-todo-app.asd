;;; cl-ohm-todo-app.asd

(in-package :asdf-user)

(defsystem #:cl-ohm-todo-app
  :version "0.1"
  :author "Sebastian Christ"
  :mailto "rudolfo.christ@gmail.com"
  :license "MIT"
  :depends-on (:hunchentoot
               :cl-ohm
               :cl-markup)
  :components ((:module "src"
                        :components
                        ((:file "cl-ohm-todo-app")
                         (:file "data")
                         (:file "routes"))))
  :description "CL-OHM usage example.")
