;;; routes.lisp

(in-package :cl-ohm-todo-app)

(define-easy-handler (home :uri "/") ()
  (redirect "/todos"))

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
          (unless (zerop (ohm:size all-todos))
            (htm (:br)
                 (:a :href "/todos/complete-all" "Complete all todos.")))
          (:div :class "todo-container"
                (if (zerop (ohm:size all-todos))
                    (htm (:p "No tasks available."))
                    (htm
                     (:ul :class "todos"
                          (loop for todo in (ohm:elements all-todos)
                             do (htm (:li (if (string-equal (completedp todo) "t")
                                              (htm (:del (str (description todo)))
                                                   (:a :href (format nil "/todos/delete-todo?id=~A" (ohm::ohm-id todo))
                                                       "Delete task"))
                                              (htm (str (description todo))
                                                   (:a :href (format nil "/todos/mark-complete?id=~A&complete=complete" (ohm::ohm-id todo))
                                                       "Complete task"))))))))))))))
    (:post
     (ohm:create 'todo :description description)
     (redirect "/todos"))))

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

(define-easy-handler (mark-complete :uri "/todos/mark-complete")
    (id complete)
  (let ((todo (filter-id 'todo id)))
    (when complete
      (setf (completedp todo) t)
      (ohm:save todo)))
  (redirect "/todos"))

(define-easy-handler (delete-todo :uri "/todos/delete-todo")
    (id)
  (ohm:del (filter-id 'todo id))
  (redirect "/todos"))

(define-easy-handler (complete-all :uri "/todos/complete-all") ()
  (ohm:with-connection ()
    (ohm:with-transaction
      (let ((todos (ohm:elements (filter 'todo))))
        (dolist (todo todos)
          (setf (completedp todo) t)
          (ohm:save todo)))))
  (redirect "/todos"))
