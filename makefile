default:
	cat makefile | grep ^[a-z]

.PHONY: test
test:
	-rake rubocop:autocorrect_all
	rake test
	rake act

f:
	-rake rubocop:autocorrect_all

u:
	chmod 755 exe/*
	make test
	make commit

commit:
	git status
	sleep 3
	git add .
	git commit -am 'update'

