; -*-Lisp-*-
(require 'package)

;; add some package repos
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(setq use-package-always-ensure t)
(package-initialize)

;; install use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; show directory in title
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; show directory in mode-line-buffer
(setq-default mode-line-buffer-identification
              (let ((orig  (car mode-line-buffer-identification)))
                `(:eval (cons (concat ,orig (abbreviate-file-name default-directory))
                              (cdr mode-line-buffer-identification)))))

;; make PATH in emacs match PATH from env
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; install xcscope and set keybinds
(require 'xcscope)
(global-set-key "\C-cc" 'cscope-find-functions-calling-this-function)
(global-set-key "\C-cs" 'cscope-find-this-symbol)

;; install and use undo-fu
(use-package undo-fu
  :ensure t)

;; copy to system clipboard
(setq select-enable-clipboard t)

;; install and use helm
(use-package helm
  :ensure t
  :init
  (helm-mode 1)
  (customize-set-variable 'helm-ff-lynx-style-map t))

;; install and use evil-mode and evil-leader-mode
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (evil-mode t)
  (setq evil-overriding-maps nil)
  (setq evil-intercept-maps nil)
  (setq-default evil-symbol-word-search t)
  (use-package evil-leader
    :ensure t)
  (global-evil-leader-mode)
  (evil-leader/set-leader ",")
  (evil-leader/set-key
    "cc" 'comment-line
    "cu" 'comment-line
    "ev" '(lambda () (interactive)(split-window-horizontally) (other-window 1) (find-file "~/.emacs"))
    "g" 'magit-status
    "h" '(lambda () (interactive)(split-window-vertically) (other-window 1))
    "r" 'evil-replace-line
    "s" 'evil-search-word-forward
    "S" 'evil-search-word-backward
    "v" '(lambda () (interactive)(split-window-horizontally) (other-window 1))
    "w" 'whitespace-cleanup))

(use-package evil-collection
  :init
  (evil-collection-init))

;; install magit
(use-package magit
  :ensure t)

;; install and use vdiff
(use-package vdiff
  :ensure t
  :init
  (evil-define-key 'normal vdiff-mode-map "," vdiff-mode-prefix-map))

;; install and use itail
(use-package itail
  :ensure t)

;; install and use flycheck
(use-package flycheck
  :hook (prog-mode . flycheck-mode))

;; install and use company
(use-package company
  :hook (prog-mode . company-mode)
  :config (setq company-tooltip-align-annotations t)
          (setq company-minimum-prefix-length 1))

;; install and use lsp-mode
(use-package lsp-mode
  :commands lsp
  :config (require 'lsp-clients)
  :init (setq lsp-rust-analyzer-server-display-inlay-hints t))

(use-package lsp-ui)

;; install and use toml-mode
(use-package toml-mode
  :ensure t)

;; install and use rust-mode
(use-package rust-mode
  :ensure t
  :hook (rust-mode . lsp)
  :init (setq rust-format-on-save t))

;; install and setup cargo
(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode))

;;install and use flycheck-rust
(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

;; install and use go-mode
(use-package go-mode
  :ensure t
  :config
  (add-hook 'before-save-hook #'gofmt-before-save))

;; install and use ag
(use-package ag
  :ensure t)

;; install and use KeyChord
(use-package use-package-chords
  :ensure t
  :init
  ;; Exit insert mode by pressing jj
  (setq key-chord-two-keys-delay 0.1)
  (key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
  (key-chord-mode 1))

;; install and use hightlight-parentheses
(use-package highlight-parentheses
  :ensure t
  :init
  (global-highlight-parentheses-mode t))

;; install and use line-relative
(use-package linum-relative
  :ensure t
  :init
  (linum-relative-global-mode)
  (helm-linum-relative-mode 1)
  (setq linum-relative-current-symbol "")
  (setq linum-relative-backend 'display-line-numbers-mode))

;; install and use jedi
(use-package jedi
  :ensure t
  :init
  (add-hook 'python-mode-hook 'jedi:setup)
  (setq jedi:complete-on-dot t))

;; install and use yasnippet
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config
  (setq yas-snippet-dirs
        '("~/.emacs.d/snippets"))
  (yas-global-mode 1))

;; don't follow symlinks
(setq vc-follow-symlinks nil)

;; always have a newline at the end of file
(setq require-final-newline t)

;; use 4 spaces for tab
(setq-default indent-tabs-mode nil)
(setq tab-stop-list (number-sequence 4 200 4))

;; movement keys
;; wrapper for movement keys to allow moving between emacs and tmux
((lambda ()
   (require 'windmove)

   (defun sebwindmove (thewindmovefun thetmuxparam)
     "wrap windmove commands, and if there's no window above, try switching tmux pane instead"
     (interactive)
     (condition-case nil
         (funcall thewindmovefun)
       (error (shell-command (concat "tmux select-pane " thetmuxparam)))))

    (defun sebwindmove-up () (interactive) (sebwindmove 'windmove-up "-U"))
    (defun sebwindmove-down () (interactive) (sebwindmove 'windmove-down "-D"))
    (defun sebwindmove-left () (interactive) (sebwindmove 'windmove-left "-L"))
    (defun sebwindmove-right () (interactive) (sebwindmove 'windmove-right "-R"))

    (global-set-key (kbd "M-k") 'sebwindmove-up)
    (global-set-key (kbd "M-j") 'sebwindmove-down)
    (global-set-key (kbd "M-h") 'sebwindmove-left)
    (global-set-key (kbd "M-l") 'sebwindmove-right)))

(global-set-key (kbd "C-u") 'evil-scroll-up)
(define-key evil-motion-state-map ";" 'evil-ex)
(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)
(global-set-key "\C-ch" help-map)

;; disable menu, scroll, and tool bars
(menu-bar-mode -1)
;; (toggle-scroll-bar -1)
(tool-bar-mode -1)

;; make tab completion case insensitive
(setq completion-ignore-case t)

;; automatically cleanup whitespaces on save
(add-hook 'before-save-hook 'whitespace-cleanup)


;; load lisp files
(load "~/.emacs.d/cheat-sh.el")

;; custom functions
;; paste from 0 buffer
(defun evil-replace-line ()
  (call-interactively 'evil-delete-whole-line)
  (interactive)
  (let ((evil-this-register ?0))
    (call-interactively 'evil-paste-before)))


;; highlight TODO
(defun font-lock-comment-annotations ()
  "Highlight a bunch of well known comment annotations.

This functions should be added to the hooks of major modes for programming."
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|OPTIMIZE\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(add-hook 'prog-mode-hook 'font-lock-comment-annotations)


;; delete line include indentation
;; (defun smart-kill-whole-line (&optional arg)
;;   "A simple wrapper around `kill-whole-line' that respects indentation."
;;   (interactive "P")
;;   (kill-whole-line arg)
;;   (back-to-indentation))


;; STUFF BELOW THIS HAVE BEEN ADDED BY EMACS -- DO NOT  TOUCH
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("db0cdee31f9d020b9da992d31769a77c950636ca492e067063a2fb3037fed142" "1c182f2b54258a6ecb2d42fc88ca6c4547b3b1613f3078c1a6efbacd67efaced" "052deaeefe794107aa0588055ca19d84941a652491c8e772546e85333d689d9b" "f0ad244230ef3b8ddd70a522da61ed3061f32bc83ea83b13edaf57e0117f0bd0" "929628d104cda441ef58005cfb479ca48de1a1f51669a98b966a63f0ec7dae0a" "5e372e9f16c03b83c37d1eb801708ab70e8bfde94eff57b540c1c7ed88d8a62b" "9bce34092434c6176e0012e86ecbe933c5ad66a4595526b38d3ce75f33e0ddb8" "3c732c5484a01f36135b761f812664c4d9dfa4245be3a02b8946a21f9836228b" "f3906f78cd0d890557d375f411f5e31a07caf1223880e4b10febc09bff7b2512" "255c90dcb358bf1c66b48e71a99ca0e660f9cac33abc92ebbc5b150a65340955" "36e4227cdc0b66ba4df64953bfe3aa0a9662589a938f1c10a1e4fa8a6f1f478a" "11307f7e3e91340ec2c90023acf550964439f2eb2064d0b9c91827aa37acf8d9" "a8aae96f0b49217508a20373f20aeeecd7033543e6c88e5d9e4827bba4d14614" "cd3f203f07cd2cd2689095312e465a7b02a80aec2de23a98e89c7784014a2f47" "e78a16f939d5de4127e4985a66e8bf436fc7db28056afebcf7f2283b7b8c9c3c" "9172516c29ae006dc9b753ebff29a6829d06762996faf476d803bfcdc2199ee2" "a44e215aa713c9ddf39ce7f081449584019c36224ea5ea9cf3d9408d5c3d90ca" "c31aa8426dd50465317dbb7f4996eb75c5a41908e1457a6c49ebda5b09456071" "6159d606efb6ddb151c1a9cd7c4d556fa87f674d40aa64322f863cace80414f6" "32333ad3bd794009959b5415507d4cc83709f1846f2a1adaab6697f35c98d1eb" "b3d67dca319a9bf48ed895bceb46f639f09e352e012df6ebf14a29dedbde88eb" "e269ece65abc79aee0ee06ef1a18009f2afc3cd2b630a3b02e32ed1c6bed0df7" "096ff8a26321bce1193ea7b67d08600b788a44d99a88488cc92e6b1bb2bb90ef" "dafa4ad7ba6d91c2e0393e67f707a1b72639ce23066cb8c70a9e1b6ef745e95e" "83fe900c25b0f8d6a1c0bf53851fabca8b2f65ad640e3f4ed63e953f8e466201" "afe38192ab103d924789847c6a987a8506200436c9f1cac02e93e6f121d4aa27" "6cdddb0a0121e39b0ed3f34cb3ded4d7d4cc29c2355bee9943444202b0dbb66c" "0e69e61efa36346a6a2d6f5a18b4c98034de0fa4f637b172778052a8e58e8673" "3aa134f497b69958f2670302c2631aa20aa6175dc2f56f3a1a815404353814ca" "3107032a792cba59cce40323a174462a763da64a737b988d82ee32282bf61260" "176b50b2a202582cdcb6471c5aa564bb5e095bfc102c3bae41e85b6ea060a2db" "5653e2e0294cddd710fe30b82213ad8c42730a4f31b6298f0be5b8cd5ab28bf0" "89e8ee3a9bdf9c640b0ada9257ed8d233f5c8956b0dc6f3883f1f89d152d6000" "708f2cf0f1d3987d0d63ff3f1dead69dd64d8dad406f0d8f1ceab6235b8372a8" "cb8b8501b62d9e4ce3acfb365ce10573d44bb3f7ab9c7314a9d8f05bfea5e9c9" "ad47ac12ebc2739042ae0e337c08965a2567627dc10cbcf82e142fd81ccc5b3e" "f681fc3c67d83c06c032bcdec97c625374d34aa70e29dd88bd5b11abf10a3fc9" "b2f514ea1dd766e3469edb761f8ecd608b0a801e9a2d8afb15fa89e986b49074" "f93c3c87e08fc3cd00deb6328c29723760e63a01875016f89b49c9dd283de85f" "9557200dc707fec142bf5f7c53d507d65839b78ba0224c672a1f476f4fc16c85" "c3cce5948c9938acabcdb80e9275dbd75970124a4c795a9103edb34eb913d0f6" "c0a2cc139b3ce5c045967cce9c77c016fe76621299232ea2a69fbe4e5b596d8a" "39e2e61f956932b0a1c69c0e0c6e198891b7ca9d8d51d68bc676dc59c7522b38" "87df2b7d7becbb95009290c9b05507f76920a2bc21990d59a324074cce59ad7a" "1cd6b7e6ee7d4b80c5e8e2381c19dc65b423479f7b709c34434987d2a306d3b0" "e268f2cf0fb9960b0d442c384176e20d06a1400cc4a4b9b89891844961ce475b" "f0b2d5a9d44cede26e7d7de8295b70a315224c5b471a7f1bb042d64da59469fe" "0cb338ebe98a544a002750d81604ab5c3ad4e3252244efee58f38f98cd713d80" "339739e972dee7c6d0604fe0ddc67ea86f3de840ccd8f4477ed44250f47ceaee" "c8c4400bd51874aaeb6ef195e55f2c14ee8a24a4fe97fdad3b148735d8c52c94" "0ed43e1b33df3afa13a11ebf00c5df8a789b3dc9c916cf529237661feabafde9" "5f4648135cc3ca6eaad0bef687a5bfa562fcf79c45aef136e8cd6464001a317f" "fc4c3d0047ee24ca814201d7b9035be560f5465f4170c1db9c02e73f5e47a2ae" "7cf32b29846764ca4fda6a87f82452e0f318632e1c60a0c05cac0041788fb405" "53ef961995126eaef0feba0edf489eae8edd5efc6a3d3ed423d3d065c1eb9395" "0d9f647b85ca64bdfe866ebbd03c2e5f0635035d0988cd6729a64d069e6dfb72" "2436273495d794dbf6eb939d2ac715fe98373a1cbedd9aa12410b6cca89bcdbe" "27468f368a9621c3d7f37ec120db689790f3146bce9d4d2d97f6884b0a7af5fe" "cfee4c69cca46fa3467aaedfce618c3deab5d7602317c341c4bcce68a7a19ae8" "fface28dc6c351636f685bbbf96fc20f440a7b8cb5740a04119f57bcf53099b2" "316428196483418a94e00a78b846e7e4cb3b5c595949a1ca4a99ba3efe719998" "f7fa3ba83337186bbe80587e13137eb0fd62a86458161007c383dc8582b8bd76" "0f0689423efe83497f92fb8d5927519a45f3eac32dae03349e4ae3cbefab9d02" "6c90798c6efed583ba124a0ab421c7f9ac680cfbf58765545a5f0bf470ebff90" "c6fd74011e1917a1e2998f856bac60f9d3caf2103e96ef8c857d32c2b359dce4" "718ccf96776ae0722e0af2825468be90f70183ce0d1e4e47fc983cd5cfc6b4a3" "acecafe86e0380b553b720692795d5cc060444c1ab1d2c61070d894343f7c1e0" "69859f6ce89f8e9f2e38280c1a6d6dbcfe81e3d85191451bee79d5caee7017b6" "745fec8bfc9e696f9cb86ddf18dfaf987497e67b210a1f3591efecd38477c4c3" "76b6f96a332abe23b847c656016c6fc88913911187df98f370ba6eb8c7315d04" "52ee6f22cc241436418a422d2b28caa9648d70dfd15b823581ac838fdb48cfee" "454fb05347faae1bc3837f5ac3b801329b1c1d5573b1f99e62f0311b07e68f26" "8024c5c747c06269707e0915736d29c198450552fd3c3f4ded674e26ebc13d6a" "f57cbd030f1546894ee5d370d1980550b2988db1372e172d029415b7a8ccc720" "4882248f15ad328b6d6804e0a9dc66d571d82cb6bf39033b87475b63fd9f0ee4" "8d1b3c0ff18e8486eb8e285f28bf7035fa817c7f717674ce153eaf713ab8a328" "212210962f275a40bad3ca4097e1b21a8b5f08ad18a3231c3840f03fb76754eb" "78886d44dab66e5f363feec3e977b95c510651bf834a8d01e90485542891ff5b" "0df4e299022b39083a66c863e2dd61bd85f0f254100ff0a0ccfa8fe0cced9a61" "983d24a23114dffb678f67ae2c2e16d55dc12f9ece259217bf77babf8084704d" "d0a71606f6b7225940f6520cc2a3b987656330df5f1cbf15a5af8be6862aedf0" "a09129310a90cb934d4d5e7bb61a64b5d0a0caf77ddad72f63ffa12831b9eda0" "c57251f8ce8e2c68a0af98de12622e98b9b619fa298630d9ebf692c18577a758" "2f73cf3cf93cb580a77ffc5ed381083629ecd34b55a5887df45563823232e560" "eadc30470e8959dfe3b4f818d00df3c7e430cc2d1c16cbe3713807b24c6bbaf6" "4175429b1d944d188713cb7b2e26e84d999a632fa2c752f06ca227bb3387db5c" "077430b73f4bb074d7f2c96459d61ed9649cd4e3c22c269f152a5daef4ef1c23" "509d86927fba15e666958bae527c2a8c5b9bc93ab5c2c023b05785664c41b2c6" "8a28b2a5e28d283f96f4e20df695ee786aeb3265a90cb8d16d8307c5a18c3e44" "c73aa85bcb789e1fe9b380bc6503b3bf7becfec0e09d8e0bfdc155ac9771e38c" "b97ee416ca586835bf02d32808acbe6953cef86ea7551c6cdab20cd7a962eeca" "f1175e066e8962e0e4c1c80c23093bb79063aa4a9e1506aef9fd181de909c719" "5b9e3ad7086ab08b55a71aabc43316da42e17749fb060f311d93fd6bb6e1a986" "c44726b9dff71699d673bc127a989169c6f27f52db9af37619f933c4be1d83eb" "e768651276b183145181b461c366e9a5ea80dfe6556c80ed3e76494e7a0030b0" "b4551b56d24ae5d7f0b56ed7a89d1be68ba9fcf34e30a34cca3ac2076a1e8d83" "ab782c6e58d39d5d61c7d09710e437cae304fb50610ca7fc0a16b438d83be108" "720f46112cee39ef5929838534b2dba7c91afae90c3121f38ee858957e454bdb" "8000c9a88af3ccf764f48298ebe1fbe21b5b8f9e8145fe2d54ce0bf7432d7156" "54cec2f091bd93068a31a655bb0a5e92e27936ea74f91a6c533b0165c48b42ac" "8b8807f6e466daa85aba588145eed801adb76e42598b4ac1ee9670de5823c0ae" "0fa58795c8758f5947a392e60f4753aa981dfcb99445ec686aa9feee7fcc60d1" "2e92f90b826767202f9cc692ad0416d30312d7e7edd25fdb312bc1cb3c364a9b" "0c09ed1221b9eb700b25edcf4dea2d52e231916d04f18dcf54fc854ffd92970d" "c3c0a3702e1d6c0373a0f6a557788dfd49ec9e66e753fb24493579859c8e95ab" default)))
 '(evil-undo-system (quote undo-fu))
 '(helm-completion-style (quote emacs))
 '(helm-ff-lynx-style-map t)
 '(helm-minibuffer-history-key "M-p")
 '(package-selected-packages
   (quote
    (flycheck-rust exec-path-from-shell undo-fu yasnippet jedi ag undo-fu-session magit-p4 evil-collection vdiff whitespace-cleanup-mode itail xcscope evil-magit magit git highlight-parentheses spacemacs use-package-chords buffer-move evil-leader linum-relative KeyChord helm Helm use-package evil-visual-mark-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; END OF STUFF EMACS ADDED

;; molokai theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(setq molokai-theme-kit t)
(load-theme 'molokai)
