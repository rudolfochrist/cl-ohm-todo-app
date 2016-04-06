;;; routes.lisp

(in-package :cl-ohm-todo-app)

(define-easy-handler (home :uri "/") ()
  (hunchentoot:redirect "/todos"))

(define-easy-handler (index :uri "/todos")
    ((description :request-type :post))
  (ecase (hunchentoot:request-method*)
    (:get
     (let ((all-todos (filter 'todo)))
       (with-html-output-to-string (output nil :prologue t :indent t)
         (:head
          (:title "Simple Task Manager"))
         (:body
          (:h1 "VSTM -- A Very Simple Task Manager")
          (:a :href "/todos/new" "Add new task")
          (:div :class "todo-container"
                (if (zerop (ohm:size all-todos))
                    (htm (:p "No tasks available."))
                    (loop for todo in (ohm:elements all-todos)
                       do (htm
                           (:ul :class "task"
                                (:li (description todo)))))))))))
    (:post
     (format nil "Got it ~A" description))))

(define-easy-handler (new :uri "/todos/new") ()
  (with-html-output-to-string (out nil :prologue t :indent t)
    (:head
     (:title "Create new task."))
    (:body
     (:h1 "New task")
     (:form :action "/todos" :method "post"
            (:input :type "textfield" :name "description")
            (:input :type "submit" :value "Create")
            (:a :href "/todos" "Cancel")))))
