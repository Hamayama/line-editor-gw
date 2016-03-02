;;
;; testing text.console and text.line-edit
;;

(cond-expand
 [gauche.os.windows
  (add-load-path "." :relative)
  (display #\cr)(flush) ; allocate console
  ]
 [else])

(use gauche.test)
(use file.util)

(define old-err-port (current-error-port (open-output-file (null-device))))


(test-start "text.console")

(cond-expand
 [gauche.os.windows
  (require "console")
  (import text.console)]
 [else
  (use text.console)])

(test-module 'text.console)
(test-end)


(test-start "text.line-edit")

(cond-expand
 [gauche.os.windows
  (require "line-edit")
  (import text.line-edit)]
 [else
  (use text.line-edit)])

(test-module 'text.line-edit)
(test-end)


(current-error-port old-err-port)
(print "HIT ENTER KEY!")
(flush)
(read-line)


