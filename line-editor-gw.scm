;; This program is modified for Windows.

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
  (use mscon)
  (use mscontext)
  (use line-edit)]
 [else
  (use text.console)
  (use text.line-edit)])

(use gauche.listener :only (complete-sexp?))
(use gauche.vport)

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
        ((0 1)
         (print "SJIS MODE")
         (msjis-mode 0 'SJIS #f)
         (set! (~ con 'iport) (current-input-port))
         (set! (~ con 'oport) (current-output-port))
         (set! (~ ctx 'wide-char-disp-width) 2)
         (set! (~ ctx 'wide-char-pos-width)  2)
         )
        ((2)
         (print "UTF-8 MODE (for ConEmu)")
         (msjis-mode 0 'UTF-8 #t)
         (set! (~ con 'iport) (current-input-port))
         (set! (~ con 'oport) (current-output-port))
         (set! (~ ctx 'wide-char-disp-width) 2)
         (set! (~ ctx 'wide-char-pos-width)  1)
         )
        ((3)
         (print "UTF-8 MONOSPACE MODE (for ConEmu)")
         (msjis-mode 0 'UTF-8 #t)
         (set! (~ con 'iport) (current-input-port))
         (set! (~ con 'oport) (current-output-port))
         (set! (~ ctx 'wide-char-disp-width) 1)
         (set! (~ ctx 'wide-char-pos-width)  1)
         )
        (else
         (print "ASCII MODE")
         )))]
 [else])

    ;(let loop ()
    ;  (let1 line (read-line/edit ctx)
    ;    (newline)
    ;    ;(if (eof-object? line) (exit 0))
    ;    (print line)
    ;    (inc! count)
    ;    (loop)))))
    (let* ((p (make <virtual-input-port>
                    :getc
                    (let1 p (open-input-string "")
                      (lambda ()
                       (let loop ((ch (read-char p)))
                         (cond
                          ((eof-object? ch)
                           (set! p (open-input-string
                                    (string-append (read-line/edit ctx)
                                                   (string #\newline))))
                           (newline)
                           (inc! count)
                           (loop (read-char p)))
                          (else
                           ch)))))))
           (reader    (lambda () (read p)))
           (evaluator #f)
           (printer   #f)
           (prompter  (lambda ())))
      (read-eval-print-loop reader evaluator printer prompter))))

