;; This program was modified for Windows.

;;
;; Sample of text.line-edit
;;

;; Just reads a line at a time and echoes back.

(cond-expand
 [gauche.os.windows
  (add-load-path "." :relative)
  (display #\cr)(flush) ; allocate console
  ]
 [else])

(cond-expand
 [gauche.os.windows
  (use msjis)
  (require "console")
  (import text.console)
  (require "line-edit")
  (import text.line-edit)]
 [else
  (use text.console)
  (use text.line-edit)])

(use gauche.listener :only (complete-sexp?))
(use gauche.vport)
(use gauche.interactive)

(define (main args)
  (let* ([con (guard (e [else (exit 1 (~ e'message))])
                (make-default-console))]
         [count 0]
         [ctx (make <line-edit-context>
                :console con
                :prompt (^[] (format #t "[~d]$ " count))
                :input-continues (^s (not (complete-sexp? s))))])

(cond-expand
 [gauche.os.windows
    ;(print args)
    (let1 arg1 (if (and (list? args) (>= (length args) 2))
                 (list-ref args 1)
                 "")
      (case (x->integer arg1)
        ((1)
         (print "SJIS MODE")
         (msjis-mode 0 'SJIS #f)
         (set! (~ ctx 'wide-char-disp-width) 2)
         (set! (~ ctx 'wide-char-pos-width)  2)
         (set! (~ ctx 'surrogate-char-disp-width) 4)
         (set! (~ ctx 'surrogate-char-pos-width)  4))
        ((2)
         (print "UTF-8 MODE (for ConEmu)")
         (msjis-mode 0 'UTF-8 #t)
         (set! (~ ctx 'wide-char-disp-width) 2)
         (set! (~ ctx 'wide-char-pos-width)  1)
         (set! (~ ctx 'surrogate-char-disp-width) 2)
         (set! (~ ctx 'surrogate-char-pos-width)  2))
        ((3)
         (print "UTF-8 MONOSPACE MODE (for ConEmu)")
         (msjis-mode 0 'UTF-8 #t)
         (set! (~ ctx 'wide-char-disp-width) 1)
         (set! (~ ctx 'wide-char-pos-width)  1)
         (set! (~ ctx 'surrogate-char-disp-width) 2)
         (set! (~ ctx 'surrogate-char-pos-width)  2))
        ((4)
         (print "UTF-8 BUT CP932 MODE (for ConEmu) (for winpty)")
         (msjis-mode 0 'UTF-8 #t)
         (set! (~ ctx 'wide-char-disp-width) 2)
         (set! (~ ctx 'wide-char-pos-width)  2)
         (set! (~ ctx 'surrogate-char-disp-width) 4)
         (set! (~ ctx 'surrogate-char-pos-width)  4))
        ((0 5)
         (print "UTF-8 MODE (for Mintty)")
         (msjis-mode 0 'UTF-8 #t)
         (set! (~ ctx 'wide-char-disp-width) 2)
         (set! (~ ctx 'wide-char-pos-width)  2)
         (set! (~ ctx 'surrogate-char-disp-width) 2)
         (set! (~ ctx 'surrogate-char-pos-width)  2))
        (else
         (print "ASCII MODE")
         )))]
 [else])

    ($ call-with-console con
       (lambda (con)
         (let* ((p (make <virtual-input-port>
                     :getc
                     (let1 p1 (open-input-string "")
                       (lambda ()
                         (let loop ((ch (read-char p1)))
                           (cond
                            ((eof-object? ch)
                             (let1 str (read-line/edit ctx #f)
                               (if (eof-object? str) (set! str "(eof-object)"))
                               (set! p1 (open-input-string
                                         (string-append str (string #\newline))))
                               (newline)
                               (flush)
                               (inc! count)
                               (loop (read-char p1))))
                            (else
                             ch)))))))
                (reader    (lambda ()
                             (with-input-from-port p
                               (with-module gauche.interactive %reader))))
                (evaluator (lambda (expr env)
                             ($ call-with-console con
                                (lambda (con)
                                  ((with-module gauche.interactive %evaluator) expr env))
                                :mode 'cooked)))
                (printer   #f)
                (prompter  (lambda ())))
           (read-eval-print-loop reader evaluator printer prompter)))
       :mode 'rare)))

