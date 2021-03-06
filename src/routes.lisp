;;; routes.lisp

(in-package :cl-ohm-todo-app)

(define-easy-handler (home :uri "/") ()
  (redirect "/todos"))

(define-easy-handler (index :uri "/todos")
    ((description :request-type :post))
  (ecase (hunchentoot:request-method*)
    (:get
     (let* ((all-todos (ohm:elements (filter 'todo)))
            (active-todos (loop for todo in all-todos count (string-equal "nil" (completedp todo)))))
       (with-html-output-to-string (output nil :prologue t :indent t)
         (:head
          (:title "Simple Task Manager"))
         (:body
          (:h1 "VSTM -- A Very Simple Task Manager")
          (:a :href "/todos/new" "Add new task")
          (unless (zerop (length all-todos))
            (htm (:br)
                 (:a :href "/todos/complete-all" "Complete all todos.")
                 (:br)
                 (:a :href "/todos/cleanup" "Remove comleted tasks.")
                 (:p (fmt "~D item~P left" active-todos active-todos))))
          (:div :class "todo-container"
                (if (zerop (length all-todos))
                    (htm (:p "No tasks available."))
                    (htm
                     (:ul :class "todos"
                          (loop for todo in all-todos
                             do (htm
                                 (:li
                                  (if (string-equal (completedp todo) "t")
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
  (dolist (todo (ohm:elements (filter 'todo)))
    (setf (completedp todo) t)
    (ohm:save todo))
  (redirect "/todos"))

(define-easy-handler (cleanup :uri "/todos/cleanup") ()
  (dolist (todo (ohm:elements (filter 'todo)))
    (when (string-equal (completedp todo) "t")
      (ohm:del todo)))
  (redirect "/todos"))
