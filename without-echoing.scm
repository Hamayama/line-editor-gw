;; Example of termios

(cond-expand
 [gauche.os.windows
  (add-load-path "." :relative)
  (display #\cr)(flush) ; allocate console
  ]
 [else])

(use gauche.uvector)
(use gauche.termios)

(cond-expand
 [gauche.os.windows
  (require "termios_patch")]
 [else])

(define (get-password)
  (display "Password: ")
  (flush)
  (without-echoing #f read-line))

(define (main _)
  (let1 pass (get-password)
    (newline)
    (print pass)
    (print (string->u8vector pass))
    )
  0)

