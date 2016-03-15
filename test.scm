;; This program was modified for Windows.

;;
;; testing text.console, text.line-edit and gauche.termios
;;

(add-load-path "." :relative)
(display #\cr)(flush) ; allocate console for windows
(use gauche.test)
(use file.util)

(define old-err-port (current-error-port (open-output-file (null-device))))

(test-start "text.console")
;(use text.console)
(require "console")
(import text.console)
(test-module 'text.console)
(test-end)

(test-start "text.line-edit")
;(use text.line-edit)
(require "line-edit")
(import text.line-edit)
(test-module 'text.line-edit)
(test-end)

(test-start "gauche.termios")
(use gauche.termios)
(require "termios_patch")
(test-module 'gauche.termios)
(test-end)

(current-error-port old-err-port)
(print "HIT ENTER KEY!")
(flush)
(read-line)

