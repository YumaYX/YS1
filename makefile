default:
	cat makefile | grep ^[a-z]

.PHONY: test
test:
	-rake -T | grep unsafe | sh 
	rake test
	rake act

u:
	make test
	make commit

commit:
	git status
	sleep 3
	git add .
	git commit -am 'update'

