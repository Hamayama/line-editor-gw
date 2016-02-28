;;; This program was modified for Windows.

;;;
;;; termios - termios interface
;;;
;;;   Copyright (c) 2000-2015  Shiro Kawai  <shiro@acm.org>
;;;
;;;   Redistribution and use in source and binary forms, with or without
;;;   modification, are permitted provided that the following conditions
;;;   are met:
;;;
;;;   1. Redistributions of source code must retain the above copyright
;;;      notice, this list of conditions and the following disclaimer.
;;;
;;;   2. Redistributions in binary form must reproduce the above copyright
;;;      notice, this list of conditions and the following disclaimer in the
;;;      documentation and/or other materials provided with the distribution.
;;;
;;;   3. Neither the name of the authors nor the names of its contributors
;;;      may be used to endorse or promote products derived from this
;;;      software without specific prior written permission.
;;;
;;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;;   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;;   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;;   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;;   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;;   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;;;   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;;   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;;   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;;   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;;   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;;

(select-module gauche.termios)

 (cond-expand
  [gauche.os.windows
   (use os.windows)
   (use file.util)]
  [else])

 ;; mode should be either one of 'cooked, 'rare or 'raw
 ;; NB: Although we work on the given port and also calls PROC with port,
 ;; what's changed is actually a device connected to the port.  There can
 ;; be more than one port connected to the same device, and I/O thru those
 ;; ports would also be affected.
 ;; TODO: What to do with Windows console?
 (define (with-terminal-mode port mode proc :optional (cleanup #f))
   (cond-expand
    [gauche.os.windows
     (cond
      ;; MSVCRT's isatty always returns 0 for Mintty without winpty.
      [(and (sys-getenv "MSYSCON") (not (sys-isatty port)))
       (let ()
         (define saved-attr
           (rlet1 ret ""
             (receive (out tempfile)
                 (sys-mkstemp (build-path (temporary-directory) "gauche_stty"))
               (unwind-protect
                (begin
                  (close-output-port out)
                  (sys-system (string-append "stty -g > "
                                             (regexp-replace-all #/\\/ tempfile "/")))
                  (set! ret (with-input-from-file tempfile read-line)))
                (sys-unlink tempfile)))))
         (define saved-buffering (port-buffering port))
         (define new-attr
           (case mode
             [(raw)
              "-echo -icanon -iexten -isig"]
             [(rare)
              "-echo -icanon -iexten  isig"]
             [(cooked)
              " echo  icanon  iexten  isig"]
             [else
              (error "terminal mode needs to be one of cooked, rare or raw, \
                        but got:" mode)]))
         (define (set)
           (sys-system (string-append "stty " new-attr))
           (when (memq mode '(raw rare))
             (set! (port-buffering port) :none)))
         (define (reset)
           (sys-system (string-append "stty " saved-attr))
           (set! (port-buffering port) saved-buffering)
           (when cleanup (cleanup)))
         (unwind-protect (begin (set) (proc port)) (reset)))]
      [else (proc port)])]
    [else
     (cond
      [(sys-isatty port)
       (let ()
         (define saved-attr (sys-tcgetattr port))
         (define saved-buffering (port-buffering port))
         (define new-attr
           (rlet1 attr (sys-termios-copy saved-attr)
             (case mode
               [(raw)
                (set! (~ attr'iflag)
                      (logand (~ attr'iflag)
                              (lognot (logior BRKINT ICRNL INPCK ISTRIP IXON))))
                (set! (~ attr'oflag) (logand (~ attr'oflag) (lognot OPOST)))
                (set! (~ attr'cflag)
                      (logior (logand (~ attr'cflag)
                                      (lognot (logior CSIZE PARENB)))
                              CS8))
                (set! (~ attr'lflag)
                      (logand (~ attr'lflag)
                              (lognot (logior ECHO ICANON IEXTEN ISIG))))]
               [(rare)
                (set! (~ attr'iflag)
                      (logior BRKINT
                              (logand (~ attr'iflag)
                                      (lognot (logior ICRNL INPCK ISTRIP IXON)))))
                (set! (~ attr'oflag) (logand (~ attr'oflag) (lognot OPOST)))
                (set! (~ attr'cflag)
                      (logior (logand (~ attr'cflag)
                                      (lognot (logior CSIZE PARENB)))
                              CS8))
                (set! (~ attr'lflag)
                      (logior ISIG
                              (logand (~ attr'lflag)
                                      (lognot (logior ECHO ICANON IEXTEN)))))]
               [(cooked)
                (set! (~ attr'iflag)
                      (logior (~ attr'iflag)
                              BRKINT ICRNL INPCK ISTRIP IXON))
                (set! (~ attr'oflag) (logior (~ attr'oflag) OPOST))
                (set! (~ attr'lflag)
                      (logior (~ attr'lflag) ECHO ICANON IEXTEN ISIG))]
               [else
                (error "terminal mode needs to be one of cooked, rare or raw, \
                          but got:" mode)])))
         (define (set)
           (sys-tcsetattr port TCSANOW new-attr)
           (when (memq mode '(raw rare))
             (set! (port-buffering port) :none)))
         (define (reset)
           (sys-tcsetattr port TCSANOW saved-attr)
           (set! (port-buffering port) saved-buffering)
           (when cleanup (cleanup)))
         (unwind-protect (begin (set) (proc port)) (reset)))]
      [else (proc port)])]))
