;;; Load data to Postgresql blobs

(load-library "pq.so")
(defvar *dired-slurp-default-project* 0)

;;;###autoload
(defun nmap-slurp-file (name)
  (interactive "fFile:")
  (let ((db (pq:connectdb "")))
    (pq:query db "insert into nmap.xml (data, filename, project) values ($1, $2, $3)"
	      (with-temp-buffer
		(insert-file name)
		(goto-char 1)
		(forward-line)
		(kill-line) ; brutal way to remove DOCTYPE
		(if (search-forward "</nmaprun>" nil t)
		    (buffer-string)
		  "<none/>"))
	      name
	      *dired-slurp-default-project*)
    (setq db nil)))

(defun nmap-slurp-directory (dir)
  (interactive "DDirectory:")
  (let ((db (pq:connectdb "")))
    (dolist (name (directory-files dir t ".xml" t))
      (message "%s" name)
      (pq:query db "insert into nmap.xml (data, filename, project) values ($1, $2, $3)"
		(with-temp-buffer
		  (insert-file name)
		  (goto-char 1)
		  (forward-line)
		  (kill-line) ; brutal way to remove DOCTYPE
		(if (search-forward "</nmaprun>" nil t)
		    (buffer-string)
		  "<none/>"))
		name
		*dired-slurp-default-project*))
    (setq db nil)))

;;;###autoload
(defun dired-nmap-slurp-file ()
  "Read curre"
  (interactive)
  (nmap-slurp-file  (dired-get-file-for-visit)))

;;;###autoload
(with-eval-after-load "dired"
  (bind-key "<f12> N" 'dired-nmap-slurp-file dired-mode-map))
