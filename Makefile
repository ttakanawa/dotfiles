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
	@git rebase master

.PHONY: push
push:
	@git checkout master
	@git push upstream master
	@git checkout -

.PHONY: push-force
push-force:
	@git checkout master
	@git push -f upstream master
	@git checkout -