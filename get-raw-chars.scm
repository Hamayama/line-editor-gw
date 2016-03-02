;; Example of reading a raw keyboard input from console, using text.console.

(cond-expand
 [gauche.os.windows
  (add-load-path "." :relative)
  (display #\cr)(flush) ; allocate console
  ]
 [else])

(cond-expand
 [gauche.os.windows
  (require "console")
  (import text.console)]
 [else
  (use text.console)])

(define (main _)
  (for-each (^c (write c) (newline))
            (call-with-console (guard (e [else (exit 1 (~ e'message))])
                                 (make-default-console))
                               get-raw-chars))
  0)



