default:
	cat makefile | grep ^[a-z]

.PHONY: test
test:
	make fix
	rake test
	rake act

init:
	bundle install

fix:
	-rake rubocop:autocorrect_all

update:
	chmod 755 exe/*
	make test
	make commit

commit:
	git status
	sleep 3
	git add .
	git commit -am 'update'

