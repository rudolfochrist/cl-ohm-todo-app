;;; cl-ohm-todo-app.lisp

(in-package :cl-user)
(defpackage #:cl-ohm-todo-app
  (:use :cl :cl-who)
  (:import-from :hunchentoot
                #:define-easy-handler
                #:redirect)
  (:import-from :cl-ohm
                #:filter)
  (:export
   #:start-server
   #:stop-server))

(in-package :cl-ohm-todo-app)

(defparameter *acceptor* nil
  "The running hunchentoot acceptor")

(defun start-server (&optional (port 4242))
  (unless *acceptor*
    (setf *acceptor* (make-instance 'hunchentoot:easy-acceptor :port port)))
  (hunchentoot:start *acceptor*))

(defun stop-server ()
  (when (hunchentoot:started-p *acceptor*)
    (hunchentoot:stop *acceptor* :soft t)
    (setf *acceptor* nil)))
