love:
	zip -9r bin/bats\&pray.love ./*

win32: love
ifeq (,$(wildcard bin/love-win32.zip))
	wget -O bin/love-win32.zip \
		https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip
endif
	unzip -d bin/ bin/love-win32.zip
	mv bin/love-*-win32 bin/bats\&pray-win32
	rm bin/bats\&pray-win32/changes.txt
	rm bin/bats\&pray-win32/readme.txt
	rm bin/bats\&pray-win32/lovec.exe
	cat bin/bats\&pray.love >> bin/bats\&pray-win32/love.exe
	mv bin/bats\&pray-win32/love.exe bin/bats\&pray-win32/Bats\ \&\ Pray.exe
	cp doc/bin-license.txt bin/bats\&pray-win32/license.txt
	zip -9jr bin/bats\&pray-win32.zip bin/bats\&pray-win32
	rm -rf bin/bats\&pray-win32

test: love
	love bin/bats\&pray.love

clean: 
	rm -rf ./bin/*

all: love win32
