;; Copyright (C) 2003 Shawn Betts
;;
;;  This file is part of stumpwm.
;;
;; stumpwm is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; stumpwm is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
;; Boston, MA 02111-1307 USA

;; Commentary:
;;
;; This file contains primitive data structures and functions used
;; throughout stumpwm.
;;
;; Code:

(in-package :stumpwm)

(export '(*suppress-abort-messages*
          *timeout-wait*
          *timeout-frame-indicator-wait*
          *frame-indicator-timer*
          *message-window-timer*
          *new-window-hook*
          *destroy-window-hook*
          *focus-window-hook*
          *place-window-hook*
          *start-hook*
          *internal-loop-hook*
          *focus-frame-hook*
          *new-frame-hook*
          *message-hook*
          *top-level-error-hook*
          *focus-group-hook*
          *key-press-hook*
          *root-click-hook*
          *mode-line-click-hook*
          *display*
          *shell-program*
          *maxsize-border-width*
          *transient-border-width*
          *normal-border-width*
          *text-color*
          *window-events*
          *window-parent-events*
          *message-window-padding*
          *message-window-gravity*
          *editor-bindings*
          *input-window-gravity*
          *normal-gravity*
          *maxsize-gravity*
          *transient-gravity*
          *top-level-error-action*
          *window-name-source*
          *frame-number-map*
          *all-modifiers*
          *modifiers*
          *screen-list*
          *initializing*
          *processing-existing-windows*
          *executing-stumpwm-command*
          *debug-level*
          *debug-expose-events*
          *debug-stream*
          *window-formatters*
          *window-format*
          *group-formatters*
          *group-format*
          *list-hidden-groups*
          *x-selection*
          *top-map*
          *last-command*
          *max-last-message-size*
          *record-last-msg-override*
          *suppress-echo-timeout*
          *run-or-raise-all-groups*
          *run-or-raise-all-screens*
          *deny-map-request*
          *deny-raise-request*
          *suppress-deny-messages*
          *honor-window-moves*
          *resize-hides-windows*
          *min-frame-width*
          *min-frame-height*
          *new-frame-action*
          *new-window-prefered-frame*
          *startup-message*
          *default-package*
          *window-placement-rules*
          *mouse-focus-policy*
          *root-click-focuses-frame*
          *banish-pointer-to*
          *xwin-to-window*
          *resize-map*
          add-hook
          dformat
          getenv
          remove-hook
          run-hook
          run-hook-with-args
          split-string
	  with-restarts-menu))


;;; Message Timer
(defvar *suppress-abort-messages* nil
  "Suppress abort message when non-nil.")

(defvar *timeout-wait* 5
  "Specifies, in seconds, how long a message will appear for. This must
be an integer.")

(defvar *timeout-frame-indicator-wait* 1
  "The amount of time a frame indicator timeout takes.")

(defvar *frame-indicator-timer* nil
  "Keep track of the timer that hides the frame indicator.")

(defvar *message-window-timer* nil
  "Keep track of the timer that hides the message window.")

;;; Hooks

(defvar *map-window-hook* '()
  "A hook called whenever a window is mapped.")

(defvar *unmap-window-hook* '()
  "A hook called whenever a window is withdrawn.")

(defvar *new-window-hook* '()
  "A hook called whenever a window is added to the window list. This
includes a genuinely new window as well as bringing a withdrawn window
back into the window list.")

(defvar *destroy-window-hook* '()
  "A hook called whenever a window is destroyed or withdrawn.")

(defvar *focus-window-hook* '()
  "A hook called when a window is given focus. It is called with 2
arguments: the current window and the last window (could be nil).")

(defvar *place-window-hook* '()
  "A hook called whenever a window is placed by rule. Arguments are
window group and frame")

(defvar *start-hook* '()
  "A hook called when stumpwm starts.")

(defvar *internal-loop-hook* '()
  "A hook called inside stumpwm's inner loop.")

(defvar *focus-frame-hook* '()
  "A hook called when a frame is given focus. The hook functions are
called with 2 arguments: the current frame and the last frame.")

(defvar *new-frame-hook* '()
  "A hook called when a new frame is created. the hook is called with
the frame as an argument.")

(defvar *message-hook* '()
  "A hook called whenever stumpwm displays a message. The hook
function is passed any number of arguments. Each argument is a
line of text.")

(defvar *top-level-error-hook* '()
  "Called when a top level error occurs. Note that this hook is
run before the error is dealt with according to
*top-level-error-action*.")

(defvar *focus-group-hook* '()
  "A hook called whenever stumpwm switches groups. It is called with 2 arguments: the current group and the last group.")

(defvar *key-press-hook* '()
  "A hook called whenever a key under *top-map* is pressed.
It is called with 3 argument: the key, the (possibly incomplete) key
sequence it is a part of, and command value bound to the key.")

(defvar *root-click-hook* '()
  "A hook called whenever there is a mouse click on the root
window. Called with 4 arguments, the screen containing the root
window, the button clicked, and the x and y of the pointer.")

(defvar *mode-line-click-hook* '()
  "Called whenever the mode-line is clicked. It is called with 4 arguments,
the mode-line, the button clicked, and the x and y of the pointer.")

;; Data types and globals used by stumpwm

(defvar *display* nil
  "The display for the X server")

(defvar *shell-program* "/bin/sh"
  "The shell program used by @code{run-shell-command}.")

(defvar *maxsize-border-width* 1
  "The width in pixels given to the borders of windows with maxsize or ratio hints.")

(defvar *transient-border-width* 1
  "The width in pixels given to the borders of transient or pop-up windows.")

(defvar *normal-border-width* 1
  "The width in pixels given to the borders of regular windows.")

(defvar *text-color* "white"
  "The color of message text.")

(defparameter +netwm-supported+
  '(:_NET_SUPPORTING_WM_CHECK
    :_NET_NUMBER_OF_DESKTOPS
    :_NET_DESKTOP_GEOMETRY
    :_NET_DESKTOP_VIEWPORT
    :_NET_CURRENT_DESKTOP
    :_NET_WM_WINDOW_TYPE
    :_NET_WM_STATE
    :_NET_WM_STATE_MODAL
    :_NET_WM_ALLOWED_ACTIONS
    :_NET_WM_STATE_FULLSCREEN
    :_NET_WM_STATE_HIDDEN
    :_NET_WM_FULL_WINDOW_PLACEMENT
    :_NET_CLOSE_WINDOW
    :_NET_CLIENT_LIST
    :_NET_CLIENT_LIST_STACKING
    :_NET_ACTIVE_WINDOW
    :_KDE_NET_SYSTEM_TRAY_WINDOW_FOR)
  "Supported NETWM properties.
Window types are in +WINDOW-TYPES+.")

(defparameter +netwm-allowed-actions+
  '(:_NET_WM_ACTION_CHANGE_DESKTOP
    :_NET_WM_ACTION_FULLSCREEN
    :_NET_WM_ACTION_CLOSE)
  "Allowed NETWM actions for managed windows")

(defparameter +netwm-window-types+
  '(
    ;; (:_NET_WM_WINDOW_TYPE_DESKTOP . :desktop)
    (:_NET_WM_WINDOW_TYPE_DOCK . :dock)
    ;; (:_NET_WM_WINDOW_TYPE_TOOLBAR . :toolbar)
    ;; (:_NET_WM_WINDOW_TYPE_MENU . :menu)
    ;; (:_NET_WM_WINDOW_TYPE_UTILITY . :utility)
    ;; (:_NET_WM_WINDOW_TYPE_SPLASH . :splash)
    (:_NET_WM_WINDOW_TYPE_DIALOG . :dialog)
    (:_NET_WM_WINDOW_TYPE_NORMAL . :normal))
  "Alist mapping NETWM window types to keywords.
Include only those we are ready to support.")

;; Window states
(defconstant +withdrawn-state+ 0)
(defconstant +normal-state+ 1)
(defconstant +iconic-state+ 3)

(defvar *window-events* '(:structure-notify
                          :property-change
                          :colormap-change
                          :focus-change
                          :enter-window)
  "The events to listen for on managed windows.")

(defvar *window-parent-events* '(:substructure-notify
                                 :substructure-redirect)

  "The events to listen for on managed windows' parents.")

;; Message window variables
(defvar *message-window-padding* 5
  "The number of pixels that pad the text in the message window.")

(defvar *message-window-gravity* :top-right
  "This variable controls where the message window appears. The follow
are valid values.
@table @asis
@item :top-left
@item :top-right
@item :bottom-left
@item :bottom-right
@item :center
@end table")

;; line editor
(defvar *editor-bindings* nil
  "A list of key-bindings for line editing.")

(defvar *input-window-gravity* :top-right
  "This variable controls where the input window appears. The follow
are valid values.
@table @asis
@item :top-left
@item :top-right
@item :bottom-left
@item :bottom-right
@item :center
@end table")

;; default values. use the set-* functions to these attributes
(defparameter +default-foreground-color+ "White")
(defparameter +default-background-color+ "Black")
(defparameter +default-window-background-color+ "Black")
(defparameter +default-border-color+ "White")
(defparameter +default-font-name+ "9x15bold")
(defparameter +default-focus-color+ "White")
(defparameter +default-unfocus-color+ "Black")
(defparameter +default-frame-outline-width+ 2)

;; Don't set these variables directly, use set-<var name> instead
(defvar *normal-gravity* :center)
(defvar *maxsize-gravity* :center)
(defvar *transient-gravity* :center)

(defvar *top-level-error-action* :abort
  "If an error is encountered at the top level, in
STUMPWM-INTERNAL-LOOP, then this variable decides what action
shall be taken. By default it will print a message to the screen
and to *standard-output*.

Valid values are :message, :break, :abort. :break will break to the
debugger. This can be problematic because if the user hit's a
mapped key the ENTIRE keyboard will be frozen and you will have
to login remotely to regain control. :abort quits stumpmwm.")

(defvar *window-name-source* :title
  "This variable controls what is used for the window's name. The default is @code{:title}.

@table @code
@item :title
Use the window's title given to it by its owner.

@item :class
Use the window's resource class.

@item :resource-name
Use the window's resource name.
@end table")

(defstruct window
  xwin
  width height
  x y        ; these are only used to hold the requested map location.
  gravity
  group
  frame
  number
  parent
  title
  user-title
  class
  type
  res
  role
  unmap-ignores
  state
  normal-hints
  marked
  plist
  fullscreen)

(defstruct frame
  (number nil :type integer)
  x
  y
  width
  height
  window)

(defstruct (head (:include frame))
  ;; point back to the screen this head belongs to
  screen
  ;; a bar along the top or bottom that displays anything you want.
  mode-line)

(defstruct group
  ;; A list of all windows in this group. They are of the window
  ;; struct variety.
  screen
  windows
  number
  name)

(defstruct (tile-group (:include group))
  ;; From this frame tree a list of frames can be gathered
  frame-tree
  last-frame
  current-frame)

(defstruct screen
  id
  host
  number
  ;; heads of screen
  heads
  ;; the list of groups available on this screen
  groups
  current-group
  ;; various colors (as returned by alloc-color)
  border-color
  fg-color
  bg-color
  win-bg-color
  focus-color
  unfocus-color
  msg-border-width
  frame-outline-width
  font
  ;; A list of all mapped windows. These are the raw
  ;; xlib:window's. window structures are stored in groups.
  mapped-windows
  ;; A list of withdrawn windows. These are of type stumpwm::window
  ;; and when they're mapped again they'll be put back in the group
  ;; they were in when they were unmapped unless that group doesn't
  ;; exist, in which case they go into the current group.
  withdrawn-windows
  input-window
  ;; the window that accepts further keypresses after a toplevel key
  ;; has been pressed.
  key-window
  ;; The window that gets focus when no window has focus
  focus-window
  ;;
  frame-outline-gc
  ;; color contexts
  message-cc
  mode-line-cc
  ;; color maps
  color-map-normal
  color-map-bright
  ;; used to ignore the first expose even when mapping the message window.
  ignore-msg-expose
  ;; the window that has focus
  focus
  current-msg
  current-msg-highlights
  last-msg
  last-msg-highlights)

(defstruct ccontext
  win
  gc
  default-fg
  default-bright
  default-bg)

(defun screen-message-window (screen)
  (ccontext-win (screen-message-cc screen)))

(defun screen-message-gc (screen)
  (ccontext-gc (screen-message-cc screen)))

(defmethod print-object ((object frame) stream)
  (format stream "#S(frame ~d ~a ~d ~d ~d ~d)"
          (frame-number object) (frame-window object) (frame-x object) (frame-y object) (frame-width object) (frame-height object)))

(defmethod print-object ((object window) stream)
  (format stream "#S(window ~s #x~x)" (window-name object) (window-id object)))

(defvar *frame-number-map* nil
  "Set this to a string to remap the regular frame numbers to more convenient keys.
For instance,

\"hutenosa\"

would map frame 0 to 7 to be selectable by hitting the
appropriate homerow key on a dvorak keyboard. Currently only
single char keys are supported.")

(defun get-frame-number-translation (frame)
  "Given a frame return its number translation using *frame-number-map* as a char."
  (let ((num (frame-number frame)))
    (or (and (< num (length *frame-number-map*))
             (char *frame-number-map* num))
        ;; translate the frame number to a char. FIXME: it loops after 9
        (char (prin1-to-string num) 0))))

(defstruct modifiers
  (meta nil)
  (alt nil)
  (hyper nil)
  (super nil)
  (numlock nil))

(defvar *all-modifiers* nil
  "A list of all keycodes that are considered modifiers")

(defvar *modifiers* nil
  "A mapping from modifier type to x11 modifier.")

(defmethod print-object ((object screen) stream)
  (format stream "#S<screen ~s>" (screen-number object)))

(defvar *screen-list* '()
  "The list of screens managed by stumpwm.")

(defvar *initializing* nil
  "True when starting stumpwm.")

(defvar *processing-existing-windows* nil
  "True when processing pre-existing windows at startup.")

(defvar *executing-stumpwm-command* nil
  "True when executing external commands.")

;;; The restarts menu macro

(defmacro with-restarts-menu (&body body)
  "Execute BODY. If an error occurs allow the user to pick a
restart from a menu of possible restarts. If a restart is not
chosen, resignal the error."
  (let ((c (gensym)))
    `(handler-bind
      ((error
        (lambda (,c)
          (restarts-menu ,c)
          (signal ,c))))
      ,@body)))

;;; Hook functionality

(defun run-hook-with-args (hook &rest args)
  "Call each function in HOOK and pass args to it."
  (handler-case
      (with-simple-restart (abort-hooks "Abort running the remaining hooks.")
        (with-restarts-menu
            (dolist (fn hook)
              (with-simple-restart (continue-hooks "Continue running the remaining hooks.")
                (apply fn args)))))
    (error (c) (message "^B^1*Error on hook ^b~S^B!~% ^n~A" hook c) (values nil c))))

(defun run-hook (hook)
  "Call each function in HOOK."
  (run-hook-with-args hook))

(defmacro add-hook (hook fn)
  "Add a function to a hook."
  `(setf ,hook (adjoin ,fn ,hook)))

(defmacro remove-hook (hook fn)
  "Remove a function from a hook."
  `(setf ,hook (remove ,fn ,hook)))

;; Misc. utility functions

(defun conc1 (list arg)
  "Append arg to the end of list"
  (nconc list (list arg)))

(defun sort1 (list sort-fn &rest keys &key &allow-other-keys)
  "Return a sorted copy of list."
  (let ((copy (copy-list list)))
    (apply 'sort copy sort-fn keys)))

(defun mapcar-hash (fn hash)
  "Just like maphash except it accumulates the result in a list."
  (let ((accum nil))
    (labels ((mapfn (key val)
               (push (funcall fn key val) accum)))
      (maphash #'mapfn hash))
    accum))

(defun find-free-number (l &optional (min 0) dir)
  "Return a number that is not in the list l. If dir is :negative then
look for a free number in the negative direction. anything else means
positive direction."
  (let* ((dirfn (if (eq dir :negative) '> '<))
         ;; sort it and crop numbers below/above min depending on dir
         (nums (sort (remove-if (lambda (n)
                                  (funcall dirfn n min))
                                l) dirfn))
         (max (car (last nums)))
         (inc (if (eq dir :negative) -1 1))
         (new-num (loop for n = min then (+ n inc)
                        for i in nums
                        when (/= n i)
                        do (return n))))
    (dformat 3 "Free number: ~S~%" nums)
    (if new-num
        new-num
        ;; there was no space between the numbers, so use the max+inc
        (if max
            (+ inc max)
            min))))

(defun remove-plist (plist &rest keys)
  "Remove the keys from the plist.
Useful for re-using the &REST arg after removing some options."
  (do (copy rest)
      ((null (setq rest (nth-value 2 (get-properties plist keys))))
       (nreconc copy plist))
    (do () ((eq plist rest))
      (push (pop plist) copy)
      (push (pop plist) copy))
    (setq plist (cddr plist))))

(defun screen-display-string (screen)
  (format nil "DISPLAY=~a:~d.~d"
          (screen-host screen)
          (xlib:display-display *display*)
          (screen-id screen)))

;;; XXX: DISPLAY env var isn't set for cmucl
(defun run-prog (prog &rest opts &key args (wait t) &allow-other-keys)
  "Common interface to shell. Does not return anything useful."
  #+gcl (declare (ignore wait))
  (setq opts (remove-plist opts :args :wait))
  #+allegro (apply #'excl:run-shell-command (apply #'vector prog prog args)
                   :wait wait opts)
  #+(and clisp      lisp=cl)
  (progn
    ;; Arg. We can't pass in an environment so just set the DISPLAY
    ;; variable so it's inherited by the child process.
    (setf (getenv "DISPLAY") (format nil "~a:~d.~d"
                                     (screen-host (current-screen))
                                     (xlib:display-display *display*)
                                     (screen-id (current-screen))))
    (apply #'ext:run-program prog :arguments args :wait wait opts))
  #+(and clisp (not lisp=cl))
  (if wait
      (apply #'lisp:run-program prog :arguments args opts)
      (lisp:shell (format nil "~a~{ '~a'~} &" prog args)))
  #+cmu (apply #'ext:run-program prog args :output t :error t :wait wait opts)
  #+gcl (apply #'si:run-process prog args)
  #+liquid (apply #'lcl:run-program prog args)
  #+lispworks (apply #'sys::call-system
                     (format nil "~a~{ '~a'~}~@[ &~]" prog args (not wait))
                     opts)
  #+lucid (apply #'lcl:run-program prog :wait wait :arguments args opts)
  #+sbcl (apply #'sb-ext:run-program prog args :output t :error t :wait wait
                ;; inject the DISPLAY variable in so programs show up
                ;; on the right screen.
                :environment (cons (screen-display-string (current-screen))
                                   (remove-if (lambda (str)
                                                (string= "DISPLAY=" str :end2 (min 8 (length str))))
                                              (sb-ext:posix-environ)))
                opts)
  #-(or allegro clisp cmu gcl liquid lispworks lucid sbcl)
  (error 'not-implemented :proc (list 'run-prog prog opts)))

;;; XXX: DISPLAY isn't set for cmucl
(defun run-prog-collect-output (prog &rest args)
  "run a command and read its output."
  #+allegro (with-output-to-string (s)
              (excl:run-shell-command (format nil "~a~{ ~a~}" prog args)
                                      :output s :wait t))
  ;; FIXME: this is a dumb hack but I don't care right now.
  #+clisp (with-output-to-string (s)
            ;; Arg. We can't pass in an environment so just set the DISPLAY
            ;; variable so it's inherited by the child process.
            (setf (getenv "DISPLAY") (format nil "~a:~d.~d"
                                             (screen-host (current-screen))
                                             (xlib:display-display *display*)
                                             (screen-id (current-screen))))
            (let ((out (ext:run-program prog :arguments args :wait t :output :stream)))
              (loop for i = (read-char out nil out)
                    until (eq i out)
                    do (write-char i s))))
  #+cmu (with-output-to-string (s) (ext:run-program prog args :output s :error s :wait t))
  #+sbcl (with-output-to-string (s)
           (sb-ext:run-program prog args :output s :error s :wait t
                               ;; inject the DISPLAY variable in so programs show up
                               ;; on the right screen.
                               :environment (cons (screen-display-string (current-screen))
                                                  (remove-if (lambda (str)
                                                               (string= "DISPLAY=" str :end2 (min 8 (length str))))
                                                             (sb-ext:posix-environ)))))
  #-(or allegro clisp cmu sbcl)
  (error 'not-implemented :proc (list 'pipe-input prog args)))

(defun getenv (var)
  "Return the value of the environment variable."
  #+allegro (sys::getenv (string var))
  #+clisp (ext:getenv (string var))
  #+(or cmu scl)
  (cdr (assoc (string var) ext:*environment-list* :test #'equalp
              :key #'string))
  #+gcl (si:getenv (string var))
  #+lispworks (lw:environment-variable (string var))
  #+lucid (lcl:environment-variable (string var))
  #+mcl (ccl::getenv var)
  #+sbcl (sb-posix:getenv (string var))
  #-(or allegro clisp cmu gcl lispworks lucid mcl sbcl scl)
  (error 'not-implemented :proc (list 'getenv var)))

(defun (setf getenv) (val var)
  "Set the value of the environment variable, @var{var} to @var{val}."
  #+allegro (setf (sys::getenv (string var)) (string val))
  #+clisp (setf (ext:getenv (string var)) (string val))
  #+(or cmu scl)
  (let ((cell (assoc (string var) ext:*environment-list* :test #'equalp
                     :key #'string)))
    (if cell
        (setf (cdr cell) (string val))
        (push (cons (intern (string var) "KEYWORD") (string val))
              ext:*environment-list*)))
  #+gcl (si:setenv (string var) (string val))
  #+lispworks (setf (lw:environment-variable (string var)) (string val))
  #+lucid (setf (lcl:environment-variable (string var)) (string val))
  #+sbcl (sb-posix:putenv (format nil "~A=~A" (string var) (string val)))
  #-(or allegro clisp cmu gcl lispworks lucid sbcl scl)
  (error 'not-implemented :proc (list '(setf getenv) var)))

(defun pathname-is-executable-p (pathname)
  "Return T if the pathname describes an executable file."
  #+sbcl
  (let ((filename (coerce (sb-int:unix-namestring pathname) 'base-string)))
    (and (eq (sb-unix:unix-file-kind filename) :file)
         (sb-unix:unix-access filename sb-unix:x_ok)))
  ;; FIXME: add the code for clisp
  #-sbcl t)

(defun probe-path (path)
  "Return the truename of a supplied path, or nil if it does not exist."
  (handler-case
      (truename
       (let ((pathname (pathname path)))
         ;; If there is neither a type nor a name, we have a directory
         ;; pathname already. Otherwise make a valid one.
         (if (and (not (pathname-name pathname))
                  (not (pathname-type pathname)))
             pathname
             (make-pathname
              :directory (append (or (pathname-directory pathname)
                                     (list :relative))
                                 (list (file-namestring pathname)))
              :name nil :type nil :defaults pathname))))
    (file-error () nil)))

(defun split-string (string &optional (separators "
"))
  "Splits STRING into substrings where there are matches for SEPARATORS.
Each match for SEPARATORS is a splitting point.
The substrings between the splitting points are made into a list
which is returned.
***If SEPARATORS is absent, it defaults to \"[ \f\t\n\r\v]+\".

If there is match for SEPARATORS at the beginning of STRING, we do not
include a null substring for that.  Likewise, if there is a match
at the end of STRING, we don't include a null substring for that.

Modifies the match data; use `save-match-data' if necessary."
  ;; FIXME: This let is here because movitz doesn't 'lend optional'
  (let ((seps separators))
    (labels ((sep (c)
               (find c seps :test #'char=)))
      (or (loop for i = (position-if (complement #'sep) string)
                then (position-if (complement #'sep) string :start j)
                as j = (position-if #'sep string :start (or i 0))
                while i
                collect (subseq string i j)
                while j)
          ;; the empty string causes the above to return NIL, so help
          ;; it out a little.
          '("")))))

(defvar *debug-level* 0
  "Set this variable to a number > 0 to turn on debugging. The greater the number the more debugging output.")

(defvar *debug-expose-events* nil
  "Set this variable for a visual indication of expose events on internal StumpWM windows.")

(defvar *debug-stream* *error-output*
  "This is the stream debugging output is sent to. It defaults to
*error-output*. It may be more convenient for you to pipe debugging
output directly to a file.")

(defun dformat (level fmt &rest args)
  (when (>= *debug-level* level)
    (multiple-value-bind (sec m h) (decode-universal-time (get-universal-time))
      (format *debug-stream* "~d:~d:~d " h m sec))
    ;; strip out non base-char chars quick-n-dirty like
    (write-string (map 'string (lambda (ch)
                                 (if (typep ch 'base-char)
                                     ch #\?))
                       (apply 'format nil fmt args))
                  *debug-stream*)
    (finish-output *debug-stream*)))

;;; 
;;; formatting routines

(defun format-expand (fmt-alist fmt &rest args)
  (let* ((chars (coerce fmt 'list))
         (output "")
         (cur chars))
    ;; FIXME: this is horribly inneficient
    (loop
     (cond ((null cur)
            (return-from format-expand output))
           ;; if % is the last char in the string then it's a literal.
           ((and (char= (car cur) #\%)
                 (cdr cur))
            (setf cur (cdr cur))
            (let* ((tmp (loop while (and cur (char<= #\0 (car cur) #\9))
                              collect (pop cur)))
                   (len (and tmp (parse-integer (coerce tmp 'string)))))
              (if (null cur)
                  (format t "%~a" len)
                  (let* ((fmt (cadr (assoc (car cur) fmt-alist :test 'char=)))
                         (str (cond (fmt
                                     ;; it can return any type, not jut as string.
                                     (format nil "~a" (apply fmt args)))
                                    ((char= (car cur) #\%)
                                     (string #\%))
                                    (t
                                     (concatenate 'string (string #\%) (string (car cur)))))))
                    ;; crop string if needed
                    (setf output (concatenate 'string output (if len
                                                                 (subseq str 0 (min len (length str)))
                                                                 str)))
                    (setf cur (cdr cur))))))
           (t
            (setf output (concatenate 'string output (string (car cur)))
                  cur (cdr cur)))))))

(defvar *window-formatters* '((#\n window-number)
                              (#\s fmt-window-status)
                              (#\t window-name)
                              (#\c window-class)
                              (#\i window-res)
                              (#\r window-role)
                              (#\m fmt-window-marked))
  "an alist containing format character format function pairs for formatting window lists.")

(defvar *window-format* "%m%n%s%50t"
  "This variable decides how the window list is formatted. It is a string
with the following formatting options:

@table @asis
@item %n
Substitute the window number.
@item %s
Substitute the window's status. * means current window, + means last
window, and - means any other window.
@item %t
Substitute the window's name.
@item %c
Substitute the window's class.
@item %i
Substitute the window's resource ID.
@item %m
Draw a # if the window is marked.
@end table

Note, a prefix number can be used to crop the argument to a specified
size. For instance, @samp{%20t} crops the window's title to 20
characters.")

(defvar *group-formatters* '((#\n group-number)
                             (#\s fmt-group-status)
                             (#\t group-name))
  "An alist of characters and formatter functions. The character can be
used as a format character in @var{*group-format*}. When the character
is encountered in the string, the corresponding function is called
with a group as an argument. The functions return value is inserted
into the string. If the return value isn't a string it is converted to
one using @code{prin1-to-string}.")

(defvar *group-format* "%n%s%t"
  "The format string that decides what information will show up in the
group listing. The following format options are available:

@table @asis
@item %n
The group's number.

@item %s
The group's status. Similar to a window's status.

@item %t
The group's name.
@end table")

(defvar *list-hidden-groups* nil
  "Controls whether hidden groups are displayed by 'groups' and 'vgroups' commands")

(defun font-height (font)
  (+ (xlib:font-descent font)
     (xlib:font-ascent font)))

(defvar *x-selection* nil
  "This holds stumpwm's current selection. It is generally set
when killing text in the input bar.")

;; This is here to avoid warnings
(defvar *top-map* nil
  "The top level key map. This is where you'll find the binding for the
@dfn{prefix map}.")

(defvar *last-command* nil
  "Set to the last interactive command run.")

(defvar *max-last-message-size* 20
  "how many previous messages to keep.")

(defvar *record-last-msg-override* nil
  "assign this to T and messages won't be recorded. It is
recommended this is assigned using LET.")

(defvar *suppress-echo-timeout* nil
  "Assign this T and messages will not time out. It is recommended this is assigned using LET.")

(defvar *ignore-echo-timeout* nil
  "Assign this T and the message time out won't be touched. It is recommended this is assigned using LET.")

(defvar *run-or-raise-all-groups* t
  "When this is @code{T} the @code{run-or-raise} function searches all groups for a
running instance. Set it to NIL to search only the current group.")

(defvar *run-or-raise-all-screens* nil
  "When this is @code{T} the @code{run-or-raise} function searches all screens for a
running instance. Set it to @code{NIL} to search only the current screen. If
@var{*run-or-raise-all-groups*} is @code{NIL} this variable has no effect.")

(defvar *deny-map-request* nil
  "A list of window properties that stumpwm should deny matching windows'
requests to become mapped for the first time.")

(defvar *deny-raise-request* nil
  "Exactly the same as @var{*deny-map-request*} but for raise requests.

Note that no denial message is displayed if the window is already visible.")

(defvar *suppress-deny-messages* nil
  "For complete focus on the task at hand, set this to @code{T} and no
raise/map denial messages will be seen.")

(defvar *honor-window-moves* t
  "Allow windows to move between frames.")

(defvar *resize-hides-windows* nil
  "Set to T to hide windows during interactive resize")

(defun deny-request-p (window deny-list)
  (or (eq deny-list t)
      (and
       (listp deny-list)
       (find-if (lambda (props)
                  (apply 'window-matches-properties-p window props))
                deny-list)
       t)))

(defun list-splice-replace (item list &rest replacements)
  "splice REPLACEMENTS into LIST where ITEM is, removing
ITEM. Return the new list."
  (let ((p (position item list)))
    (if p
        (nconc (subseq list 0 p) replacements (subseq list (1+ p)))
        list)))

(defvar *min-frame-width* 50
  "The minimum width a frame can be. A frame will not shrink below this
width. Splitting will not affect frames if the new frame widths are
less than this value.")

(defvar *min-frame-height* 50
  "The minimum height a frame can be. A frame will not shrink below this
height. Splitting will not affect frames if the new frame heights are
less than this value.")

(defvar *new-frame-action* :last-window
  "When a new frame is created, this variable controls what is put in the
new frame. Valid values are 

@table @code
@item :empty
The frame is left empty

@item :last-window
The last focused window that is not currently visible is placed in the
frame. This is the default.
@end table")

(defvar *new-window-prefered-frame* '(:focused)
  "This variable controls what frame a new window appears in. It is a
list of preferences. The first preference that is satisfied is
used. Valid list elements are as follows:

@table @code
@item :focused
Choose the focused frame.

@item :last
Choose the last focused frame.

@item :empty
Choose any empty frame.

@item :unfocused
Choose any unfocused frame.
@end table

Alternatively, it can be set to a function that takes one argument,
the new window, and returns the prefered frame.")

(defun backtrace-string ()
  "Similar to print-backtrace, but return the backtrace as a string."
  (with-output-to-string (*standard-output*)
    (print-backtrace)))

(defun print-backtrace (&optional (frames 100))
  "print a backtrace of FRAMES number of frames to standard-output"
  #+sbcl (sb-debug:backtrace frames *standard-output*)
  #+clisp (ext:show-stack 1 frames (sys::the-frame))

  #-(or sbcl clisp) (write-line "Sorry, no backtrace for you."))

(defun utf8-to-string (octets)
  "Convert the list of octets to a string."
  #+sbcl (sb-ext:octets-to-string
          (coerce octets '(vector (unsigned-byte 8)))
          :external-format :utf-8)
  ;; TODO: handle UTF-8 for other lisps
  #-sbcl
  (map 'string #'code-char octets))

(defun string-to-utf8 (string)
  "Convert the string to a vector of octets."
  #+sbcl (sb-ext:string-to-octets
          string
          :external-format :utf-8)
  ;; TODO: handle UTF-8 for other lisps
  #-sbcl
  (map 'list #'char-code string))

(defvar *startup-message* "^2*Welcome to The ^BStump^b ^BW^bindow ^BM^banager!"
  "This is the message StumpWM displays when it starts. Set it to NIL to
suppress.")

(defvar *default-package* (find-package "CL-USER")
  "This is the package eval reads and executes in. You might want to set
this to @code{:stumpwm} if you find yourself using a lot of internal
stumpwm symbols. Setting this variable anywhere but in your rc file
will have no effect.")

(defun concat (&rest strings)
  (apply 'concatenate 'string strings))

(defvar *window-placement-rules* '()
  "List of rules governing window placement. Use define-frame-preference to
add rules")

;; FIXME: this macro doesnt use gensym, though it's also low risk
(defmacro define-frame-preference (group &rest frames)
  `(dolist (x ',frames)
     ;; verify the correct structure
     (destructuring-bind (frame-number raise lock &rest keys &key class instance type role title) x
       (push (list* ,group frame-number raise lock keys) *window-placement-rules*))))

(defun clear-window-placement-rules ()
  (setf *window-placement-rules* nil))

(defvar *mouse-focus-policy* :ignore
  "The mouse focus policy decides how the mouse affects input
focus. Possible values are :ignore, :sloppy, and :click. :ignore means
stumpwm ignores the mouse. :sloppy means input focus follows the
mouse; the window that the mouse is in gets the focus. :click means
input focus is transfered to the window you click on.")

(defvar *root-click-focuses-frame* t
  "Set to NIL if you don't want clicking the root window to focus the frame
  containing the pointer when *mouse-focus-policy* is :click.")

(defvar *banish-pointer-to* :head
  "Where to put the pointer when no argument is given to (banish-pointer) or the banish
  command. May be one of :screen :head :frame or :window")

(defvar *xwin-to-window* (make-hash-table)
  "Hash table for looking up windows quickly.")

(defvar *resize-map* nil
  "The keymap used for resizing a window")

(defmacro with-focus (xwin &body body)
  "Set the focus to xwin, do body, then restore focus"
  (let ((focus (gensym "FOCUS"))
        (revert (gensym "REVERT")))
    `(multiple-value-bind (,focus ,revert) (xlib:input-focus *display*)
       (xlib:set-input-focus *display* ,xwin :pointer-root)
       (unwind-protect
            (progn ,@body)
         (xlib:set-input-focus *display* ,focus ,revert)))))

(defvar *last-unhandled-error* nil
  "If an unrecoverable error occurs, this variable will contain the
  condition and the backtrace.")

(defvar *show-command-backtrace* nil
  "When this is T a backtrace is displayed with errors that occurred
within an interactive call to a command.")
  