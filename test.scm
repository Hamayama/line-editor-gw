;; This program was modified for Windows.

;;
;; testing text.console, text.line-edit and gauche.termios
;;

(add-load-path "." :relative)
(display #\cr)(flush) ; allocate console for windows
(use gauche.test)

(test-start "text.console")
;(use text.console)
(require "console")
(import text.console)
(test-module 'text.console)
(test-end)

(test-start "text.console.generic")
;(use text.console.generic)
(require "generic")
(import text.console.generic)
(test-module 'text.console.generic)
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

(print "HIT ENTER KEY!")
(flush)
(read-line)

