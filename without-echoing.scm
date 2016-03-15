;; This program was modified for Windows.

;; Example of termios

(add-load-path "." :relative)
(display #\cr)(flush) ; allocate console for windows
(use gauche.uvector)
(use gauche.termios)
(require "termios_patch")

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

