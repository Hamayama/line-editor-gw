;; This program was modified for Windows.

;; Example of reading a raw keyboard input from console, using text.console.

(add-load-path "." :relative)
(display #\cr)(flush) ; allocate console for windows
;(use text.console)
(require "console")
(import text.console)

(define (main _)
  (for-each (^c (write c) (newline))
            (call-with-console (guard (e [else (exit 1 (~ e'message))])
                                 (make-default-console))
                               get-raw-chars))
  0)

