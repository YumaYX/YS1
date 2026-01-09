default:
	cat Makefile | grep ^[a-z]

.PHONY: test
test:
	make fix
	rake test
	#rake act

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

podman:
	podman run --userns=keep-id --rm -v $(CURDIR):/app:Z -w /app docker.io/library/ruby:latest bash -c 'bundle install && bundle exec rake'
