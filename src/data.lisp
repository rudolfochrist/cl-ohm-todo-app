;;; data.lisp

(in-package :cl-ohm-todo-app)

(ohm:define-ohm-model todo ()
  :attributes (description completedp))
