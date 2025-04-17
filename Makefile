.PHONY: init
init:
	@git remote add upstream git@github.com:ttakanawa/dotfiles.git

.PHONY: fetch
fetch:
	@git fetch upstream
	@git checkout master
	@git merge upstream/master
	@git push origin master
	@git checkout -

.PHONY: rebase
rebase: fetch
	@git checkout -
	@git rebase master

.PHONY: set
set:
	@if [ -z "${EMAIL}" ]; then echo "ERROR: EMAIL environment variable is not set"; exit 1; fi
	@git config user.email "${EMAIL}"

.PHONY: unset
unset:
	@git config --unset user.email

.PHONY: push
push:
	@git checkout master
	@$(MAKE) set
	@git push upstream master
	@$(MAKE) unset

.PHONY: push-force
push-force:
	@git checkout master
	@$(MAKE) set
	@git push -f upstream master
	@$(MAKE) unset